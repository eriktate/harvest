#version 450 core
layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec2 in_tex_pos;
// layout (location = 2) in uint in_tex_id;

uniform uint world_width;
uniform uint world_height;
// uniform mat4 projection;

// out uint tex_id;
out vec2 tex_pos;

vec3 pos;

void main() {
	// re-map pixel coordinates to screen space
	pos = vec3(
		(in_pos.x / world_width) * 2 - 1,
		-((in_pos.y / world_height) * 2 - 1),
		in_pos.z
	);

	// gl_Position = projection * vec4(pos, 1.0);
	gl_Position = vec4(pos, 1.0);
	tex_pos = in_tex_pos;
	// tex_id = in_tex_id;
}
