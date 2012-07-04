module odyssey.geom.vertexarray;

import odyssey.math.vec3;
import odyssey.render.shader;

import derelict.opengl3.gl3;

class VertexArray {
    
    GLuint vertexArray;
    alias vertexArray this;
    
    Vec3[] positions;
    ShaderProgram shader;
    
    this(Vec3[] positions, ref ShaderProgram shader) {
        this.positions = positions;
        this.shader = shader;
        
        init();
    }
    
    void init() {
        // Create the vertex array object
        glGenVertexArrays(1, &vertexArray);
        this.bind({
            // Create the buffer object and bind the vertex data
            GLuint positionBufferObject;
            glGenBuffers(1, &positionBufferObject);
            glBindBuffer(GL_ARRAY_BUFFER, positionBufferObject);
            glBufferData(GL_ARRAY_BUFFER, positions.length * 3 * Vec3.sizeof, positions.ptr, GL_STATIC_DRAW);
            
            // Set attribute-pointers to enable communication with the shader
            GLint positionlocation = glGetAttribLocation(shader, "in_Position");
            glVertexAttribPointer(positionlocation, 3, GL_FLOAT, GL_FALSE, 0, null);
            glEnableVertexAttribArray(positionlocation);
            
            // Cleanup
            glBindBuffer(GL_ARRAY_BUFFER, 0);
        });
    }
    
    void bind(void delegate() statements) {
        glBindVertexArray(vertexArray);
        statements();
        glBindVertexArray(0);
    }
    
    void draw() {
        shader.use({
            this.bind({
                glDrawArrays(GL_TRIANGLES, 0, 3);   // Start at the 0th index and draw 3 verticies
            });
        });
    }
    
    ~this() {
        glBindVertexArray(0);
        glDeleteVertexArrays(1, &vertexArray);
    }
}