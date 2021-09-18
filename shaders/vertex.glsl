#version 330 core

layout (location = 0) in vec3 in_pos;
// layout (location = 1) in vec3 in_color;

out vec3 out_color;

void main() {
	gl_Position = vec4(in_pos, 1.0);
	out_color = vec3(1.0, 0.0, 0.0);
}
