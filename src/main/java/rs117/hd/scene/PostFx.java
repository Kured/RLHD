package rs117.hd.scene;

import javax.inject.Singleton;
import org.lwjgl.opengl.GL20C;

@Singleton
public class PostFx {

    public final float[] baseClearColor = { 0f, 0f, 0f, 0f };
    public final float[] normalClearColor = { 0.5f, 0.5f, 1.0f, 1.0f };
    public final float[] depthClearColor = { 1f, 0f, 1f, 1f };

    public PostFx() {
    }

    public void init() {
        for (PostFxShader shader : shaders) {
            //shader.uniformLocation = GL20C.glGetUniformLocation(shader.name, "u_texture");
        }
    }

    public static class PostFxShader {
        public String name = "unnamed";
        public Boolean multiPass = false;
        public int uniformLocation = -1;

        public PostFxShader(String name, Boolean multiPass) {
            this.name = name;
            this.multiPass = multiPass;
        }
    }

    // shaders rendering order and setup
    public static final PostFxShader[] shaders = new PostFxShader[] {
            new PostFxShader("aa", true),
            new PostFxShader("bloom", true),
            new PostFxShader("dof", true),
            new PostFxShader("godrays", true),
            new PostFxShader("ssao", true),
    };
}
