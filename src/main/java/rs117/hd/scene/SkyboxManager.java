package rs117.hd.scene;

import lombok.extern.slf4j.Slf4j;
import javax.inject.Singleton;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import org.lwjgl.BufferUtils;
import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.io.InputStream;


//import static org.lwjgl.opengl.GL20C.*;
//import static org.lwjgl.opengl.GL20C.*;
import static org.lwjgl.opengl.GL43C.*;

@Singleton
@Slf4j
public class SkyboxManager
{
    public SkyboxManager() {}

    public final String texPath = "rs117/hd/skybox/cubemaps/";
    public final String texType = ".png"; // .png, .jpg, hdr, .exr
    public final String texDayName = "day";
    public final String texNightName = "night";

    public int texSkyboxDay;
    public int texSkyboxNight;

    public Boolean isInit = false;

    public void init(int glProgram, int glMainProgram, int uniformSkyboxDay, int uniformSkyboxNight, int uniformMaiSkybox) {
        shutDown();
        isInit = true;

        // Load the cubemap texture
        texSkyboxDay = glGenTextures();

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_CUBE_MAP, texSkyboxDay);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_BASE_LEVEL, 0);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAX_LEVEL, 5);

        // Load and upload the individual face textures
        String[] faceFiles = {
                texDayName + "_right" + texType,
                texDayName + "_left" + texType,
                texDayName + "_top" + texType,
                texDayName + "_bottom" + texType,
                texDayName + "_front" + texType,
                texDayName + "_back" + texType
        };

        int[] faceTargets = {
                GL_TEXTURE_CUBE_MAP_POSITIVE_X,
                GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
                GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
                GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
                GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
                GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
        };

        for (int i = 0; i < 6; i++) {
            try {
                String filePath = "rs117/hd/skybox/cubemaps/" + faceFiles[i];
                InputStream imageStream = getClass().getClassLoader().getResourceAsStream(filePath);

                if (imageStream == null) {
                    throw new IOException("SkyboxManager: Failed to load image file: " + filePath);
                }

                BufferedImage image = ImageIO.read(imageStream);
                int width = image.getWidth();
                int height = image.getHeight();

                // Convert the image data to the format required by OpenGL
                int[] pixels = new int[width * height];
                image.getRGB(0, 0, width, height, pixels, 0, width);

                ByteBuffer imageBuffer = BufferUtils.createByteBuffer(width * height * 3); // Assuming RGB format

                // Convert the pixel data to the format required by OpenGL
                for (int pixel : pixels) {
                    imageBuffer.put((byte) ((pixel >> 16) & 0xFF)); // Red component
                    imageBuffer.put((byte) ((pixel >> 8) & 0xFF));  // Green component
                    imageBuffer.put((byte) (pixel & 0xFF));         // Blue component
                }

                imageBuffer.flip();

                // Upload the texture data to the current face of the cubemap
                glTexImage2D(faceTargets[i], 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, imageBuffer);
            } catch (IOException e) {
                // Handle any exceptions
                e.printStackTrace();
            }
        }

        // Set texture parameters
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_LOD_BIAS, 1.0f);
        //glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_BASE_LEVEL, 0); // sets the mip level
        //glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAX_LEVEL, 4);
        // Generate mipmapping
        glGenerateMipmap(GL_TEXTURE_CUBE_MAP);


        // Bind the shader program
        glUseProgram(glProgram);
        // Set the uniform
        glUniform1i(uniformSkyboxDay, 0); // 0 refers to the texture unit

        glUseProgram(glMainProgram);
        glUniform1i(uniformMaiSkybox, 0);

        // Reset
        glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    }

    public void shutDown()
    {
        isInit = false;

        if (texSkyboxDay != 0)
        {
            glDeleteTextures(texSkyboxDay);
            texSkyboxDay = 0;
        }
        if (texSkyboxNight != 0)
        {
            glDeleteTextures(texSkyboxNight);
            texSkyboxNight = 0;
        }
    }
}
