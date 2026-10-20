shader_type canvas_item;

uniform sampler2D powerTex : filter_nearest, repeat_disable;
uniform int channel = 0;
uniform vec2 tileSize = vec2(16.0);
uniform float gridSize = 1024.0;
uniform vec2 origin = vec2(0.0);

varying vec2 gridPos;

void vertex() {
	gridPos = ((MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy - origin) / tileSize;
}

void fragment() {
	vec2 cell = floor(gridPos) + gridSize * 0.5;
	vec4 data = texture(powerTex, (cell + 0.5) / gridSize);
	COLOR.rgb *= data[channel];
}
