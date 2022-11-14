#version 450 core
layout (location = 0) in vec3 in_pos;

uniform uint width;
uniform uint height;
uniform mat4 projection;

vec3 pos;

void main() {
	// re-map pixel coordinates to screen space
	pos = vec3(
		(in_pos.x / width) * 2 - 1,
		-((in_pos.y / height) * 2 - 1),
		in_pos.z
	);

	gl_Position = projection * vec4(pos, 1.0);
}
