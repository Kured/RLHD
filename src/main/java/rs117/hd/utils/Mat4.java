/*
 * Copyright (c) 2022 Abex
 * Copyright 2010 JogAmp Community.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package rs117.hd.utils;

public class Mat4
{
	private Mat4()
	{
	}

	public static float[] identity()
	{
		return new float[]
			{
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				0, 0, 0, 1,
			};
	}

	public static float[] scale(float sx, float sy, float sz)
	{
		return new float[]
			{
				sx, 0, 0, 0,
				0, sy, 0, 0,
				0, 0, sz, 0,
				0, 0, 0, 1,
			};
	}

	public static float[] translate(float tx, float ty, float tz)
	{
		return new float[]
			{
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0,
				tx, ty, tz, 1,
			};
	}

	public static float[] rotateX(float rx)
	{
		float s = (float) Math.sin(rx);
		float c = (float) Math.cos(rx);

		return new float[]
			{
				1, 0, 0, 0,
				0, c, s, 0,
				0, -s, c, 0,
				0, 0, 0, 1,
			};
	}

	public static float[] rotateY(float ry)
	{
		float s = (float) Math.sin(ry);
		float c = (float) Math.cos(ry);

		return new float[]
			{
				c, 0, -s, 0,
				0, 1, 0, 0,
				s, 0, c, 0,
				0, 0, 0, 1,
			};
	}

	public static float[] projection(float w, float h, float n)
	{
		return new float[]
			{
				2 / w, 0, 0, 0,
				0, 2 / h, 0, 0,
				0, 0, -1, -1,
				0, 0, -2 * n, 0
			};
	}

	public static float[] ortho(float w, float h, float n)
	{
		return new float[]
			{
				2 / w, 0, 0, 0,
				0, 2 / h, 0, 0,
				0, 0, -2 / n, 0,
				0, 0, 0, 1
			};
	}

	public static float[] perspective(float fov, float aspect, float znear, float zfar,  boolean fovIsHorizontal)
	{
		float halfSizeX = 0;
		float halfSizeY = 0;
		if (fovIsHorizontal) {
			halfSizeX = znear * (float)Math.tan(fov * Math.PI / 360);
			halfSizeY = halfSizeX / aspect;
		} else {
			halfSizeY = znear * (float)Math.tan(fov * Math.PI / 360);
			halfSizeX = halfSizeY * aspect;
		}

		return frustum(-halfSizeX, halfSizeX, -halfSizeY, halfSizeY, znear, zfar);
	}

	public static float[] frustum(float left, float right, float bottom, float top, float znear, float zfar) {
		float temp1 = 2 * znear;
		float temp2 = right - left;
		float temp3 = top - bottom;
		float temp4 = zfar - znear;

		return new float[]
				{
						temp1 / temp2, 0, 0, 0,
						0, temp1 / temp3, 0, 0,
						(right + left) / temp2, (top + bottom) / temp3, (-zfar - znear) / temp4, -1,
						0, 0, (-temp1 * zfar) / temp4, 0
				};
	}

	public static float[] transpose(final float[] a)
	{
		float[] result = new float[16];

		result[0] = a[0];
		result[1] = a[4];
		result[2] = a[8];
		result[3] = a[12];

		result[4] = a[1];
		result[5] = a[5];
		result[6] = a[9];
		result[7] = a[13];

		result[8] = a[2];
		result[9] = a[6];
		result[10] = a[10];
		result[11] = a[14];

		result[12] = a[3];
		result[13] = a[7];
		result[14] = a[11];
		result[15] = a[15];

		return result;
	}

	public static float[] inverse(final float[] a) {
		float[] result = new float[16];

		float a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3];
		float a10 = a[4], a11 = a[5], a12 = a[6], a13 = a[7];
		float a20 = a[8], a21 = a[9], a22 = a[10], a23 = a[11];
		float a30 = a[12], a31 = a[13], a32 = a[14], a33 = a[15];

		float b00 = a00 * a11 - a01 * a10;
		float b01 = a00 * a12 - a02 * a10;
		float b02 = a00 * a13 - a03 * a10;
		float b03 = a01 * a12 - a02 * a11;
		float b04 = a01 * a13 - a03 * a11;
		float b05 = a02 * a13 - a03 * a12;
		float b06 = a20 * a31 - a21 * a30;
		float b07 = a20 * a32 - a22 * a30;
		float b08 = a20 * a33 - a23 * a30;
		float b09 = a21 * a32 - a22 * a31;
		float b10 = a21 * a33 - a23 * a31;
		float b11 = a22 * a33 - a23 * a32;

		float det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
		if (det != 0) {
			float invDet = 1.0f / det;

			result[0] = (a11 * b11 - a12 * b10 + a13 * b09) * invDet;
			result[1] = (-a01 * b11 + a02 * b10 - a03 * b09) * invDet;
			result[2] = (a31 * b05 - a32 * b04 + a33 * b03) * invDet;
			result[3] = (-a21 * b05 + a22 * b04 - a23 * b03) * invDet;

			result[4] = (-a10 * b11 + a12 * b08 - a13 * b07) * invDet;
			result[5] = (a00 * b11 - a02 * b08 + a03 * b07) * invDet;
			result[6] = (-a30 * b05 + a32 * b02 - a33 * b01) * invDet;
			result[7] = (a20 * b05 - a22 * b02 + a23 * b01) * invDet;

			result[8] = (a10 * b10 - a11 * b08 + a13 * b06) * invDet;
			result[9] = (-a00 * b10 + a01 * b08 - a03 * b06) * invDet;
			result[10] = (a30 * b04 - a31 * b02 + a33 * b00) * invDet;
			result[11] = (-a20 * b04 + a21 * b02 - a23 * b00) * invDet;

			result[12] = (-a10 * b09 + a11 * b07 - a12 * b06) * invDet;
			result[13] = (a00 * b09 - a01 * b07 + a02 * b06) * invDet;
			result[14] = (-a30 * b03 + a31 * b01 - a32 * b00) * invDet;
			result[15] = (a20 * b03 - a21 * b01 + a22 * b00) * invDet;
		}

		return result;
	}

	public static void setPosition(final float[] a, float x, float y, float z )
	{
			a[ 12 ] = x;
			a[ 13 ] = y;
			a[ 14 ] = z;
	}


	public static void mul(final float[] a, final float[] b)
	{
		final float b00 = b[0 + 0 * 4];
		final float b10 = b[1 + 0 * 4];
		final float b20 = b[2 + 0 * 4];
		final float b30 = b[3 + 0 * 4];
		final float b01 = b[0 + 1 * 4];
		final float b11 = b[1 + 1 * 4];
		final float b21 = b[2 + 1 * 4];
		final float b31 = b[3 + 1 * 4];
		final float b02 = b[0 + 2 * 4];
		final float b12 = b[1 + 2 * 4];
		final float b22 = b[2 + 2 * 4];
		final float b32 = b[3 + 2 * 4];
		final float b03 = b[0 + 3 * 4];
		final float b13 = b[1 + 3 * 4];
		final float b23 = b[2 + 3 * 4];
		final float b33 = b[3 + 3 * 4];

		float ai0 = a[0 * 4]; // row-0 of a
		float ai1 = a[1 * 4];
		float ai2 = a[2 * 4];
		float ai3 = a[3 * 4];
		a[0 * 4] = ai0 * b00 + ai1 * b10 + ai2 * b20 + ai3 * b30;
		a[1 * 4] = ai0 * b01 + ai1 * b11 + ai2 * b21 + ai3 * b31;
		a[2 * 4] = ai0 * b02 + ai1 * b12 + ai2 * b22 + ai3 * b32;
		a[3 * 4] = ai0 * b03 + ai1 * b13 + ai2 * b23 + ai3 * b33;

		ai0 = a[1 + 0 * 4]; // row-1 of a
		ai1 = a[1 + 1 * 4];
		ai2 = a[1 + 2 * 4];
		ai3 = a[1 + 3 * 4];
		a[1 + 0 * 4] = ai0 * b00 + ai1 * b10 + ai2 * b20 + ai3 * b30;
		a[1 + 1 * 4] = ai0 * b01 + ai1 * b11 + ai2 * b21 + ai3 * b31;
		a[1 + 2 * 4] = ai0 * b02 + ai1 * b12 + ai2 * b22 + ai3 * b32;
		a[1 + 3 * 4] = ai0 * b03 + ai1 * b13 + ai2 * b23 + ai3 * b33;

		ai0 = a[2 + 0 * 4]; // row-2 of a
		ai1 = a[2 + 1 * 4];
		ai2 = a[2 + 2 * 4];
		ai3 = a[2 + 3 * 4];
		a[2 + 0 * 4] = ai0 * b00 + ai1 * b10 + ai2 * b20 + ai3 * b30;
		a[2 + 1 * 4] = ai0 * b01 + ai1 * b11 + ai2 * b21 + ai3 * b31;
		a[2 + 2 * 4] = ai0 * b02 + ai1 * b12 + ai2 * b22 + ai3 * b32;
		a[2 + 3 * 4] = ai0 * b03 + ai1 * b13 + ai2 * b23 + ai3 * b33;

		ai0 = a[3 + 0 * 4]; // row-3 of a
		ai1 = a[3 + 1 * 4];
		ai2 = a[3 + 2 * 4];
		ai3 = a[3 + 3 * 4];
		a[3 + 0 * 4] = ai0 * b00 + ai1 * b10 + ai2 * b20 + ai3 * b30;
		a[3 + 1 * 4] = ai0 * b01 + ai1 * b11 + ai2 * b21 + ai3 * b31;
		a[3 + 2 * 4] = ai0 * b02 + ai1 * b12 + ai2 * b22 + ai3 * b32;
		a[3 + 3 * 4] = ai0 * b03 + ai1 * b13 + ai2 * b23 + ai3 * b33;
	}
}
