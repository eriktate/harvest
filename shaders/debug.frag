#version 450 core

// in vec4 color;

out vec4 frag_color;

vec4 green = vec4(156.0f/255.0f, 240.0f/255.0f, 149.0f/255.0f, 1);
vec4 white = vec4(1.0, 1.0, 1.0, 1);

void main() {
	frag_color = white;
	// frag_color = vec4(0, 1, 0, 1);
}
