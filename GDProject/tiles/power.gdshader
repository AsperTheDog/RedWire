shader_type canvas_item;

uniform sampler2D powerTex : filter_nearest, repeat_disable;
uniform int channel = 0;
uniform vec2 tileSize = vec2(16.0);
uniform float gridSize = 1024.0;
uniform vec2 origin = vec2(0.0);

uniform bool useWires = false;
uniform bool wireDisplay = true;
uniform sampler2D wireHead : filter_nearest, repeat_disable;
uniform sampler2D wirePool : filter_nearest, repeat_disable;
uniform sampler2D sourceTex : filter_nearest, repeat_disable;

varying vec2 gridPos;

int byteOf(float v) {
	return int(v * 255.0 + 0.5);
}

float wirePower(ivec2 cell) {
	vec4 h = texelFetch(wireHead, cell, 0);
	int entry = byteOf(h.r) | (byteOf(h.g) << 8) | (byteOf(h.b) << 16);
	float best = 0.0;
	for (int i = 0; i < 64 && entry != 0; i++) {
		int texel = entry * 2;
		ivec2 at = ivec2(texel & 1023, texel >> 10);
		vec4 first = texelFetch(wirePool, at, 0);
		vec4 second = texelFetch(wirePool, at + ivec2(1, 0), 0);
		int id = byteOf(first.r) | (byteOf(first.g) << 8);
		float dist = float(byteOf(first.b));
		float sourcePower = texelFetch(sourceTex, ivec2(id & 255, id >> 8), 0).r * 255.0 / 17.0;
		best = max(best, sourcePower - dist);
		entry = byteOf(first.a) | (byteOf(second.r) << 8) | (byteOf(second.g) << 16);
	}
	return best / 15.0;
}

void vertex() {
	gridPos = ((MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy - origin) / tileSize;
}

void fragment() {
	vec2 cell = floor(gridPos) + gridSize * 0.5;
	float power = texture(powerTex, (cell + 0.5) / gridSize)[channel];
	if (useWires && wireDisplay) {
		power = max(power, wirePower(ivec2(cell)));
	}
	COLOR.rgb *= power;
}
