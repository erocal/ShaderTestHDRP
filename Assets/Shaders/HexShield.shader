Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		[HDR]_HexShieldColor ("Hex Shield Color", Color) = (1,1,1,1)
		_HexShieldMultiper ("Hex Shield Multiper", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
#define hlsl_atan(x,y) atan2(x, y)
#define mod(x,y) ((x)-(y)*floor((x)/(y)))
inline float4 textureLod(sampler2D tex, float2 uv, float lod) {
    return tex2D(tex, uv);
}
inline float2 tofloat2(float x) {
    return float2(x, x);
}
inline float2 tofloat2(float x, float y) {
    return float2(x, y);
}
inline float3 tofloat3(float x) {
    return float3(x, x, x);
}
inline float3 tofloat3(float x, float y, float z) {
    return float3(x, y, z);
}
inline float3 tofloat3(float2 xy, float z) {
    return float3(xy.x, xy.y, z);
}
inline float3 tofloat3(float x, float2 yz) {
    return float3(x, yz.x, yz.y);
}
inline float4 tofloat4(float x, float y, float z, float w) {
    return float4(x, y, z, w);
}
inline float4 tofloat4(float x) {
    return float4(x, x, x, x);
}
inline float4 tofloat4(float x, float3 yzw) {
    return float4(x, yzw.x, yzw.y, yzw.z);
}
inline float4 tofloat4(float2 xy, float2 zw) {
    return float4(xy.x, xy.y, zw.x, zw.y);
}
inline float4 tofloat4(float3 xyz, float w) {
    return float4(xyz.x, xyz.y, xyz.z, w);
}
inline float4 tofloat4(float2 xy, float z, float w) {
    return float4(xy.x, xy.y, z, w);
}
inline float2x2 tofloat2x2(float2 v1, float2 v2) {
    return float2x2(v1.x, v1.y, v2.x, v2.y);
}
// EngineSpecificDefinitions
float rand(float2 x) {
    return frac(cos(mod(dot(x, tofloat2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
float2 rand2(float2 x) {
    return frac(cos(mod(tofloat2(dot(x, tofloat2(13.9898, 8.141)),
						      dot(x, tofloat2(3.4562, 17.398))), tofloat2(3.14))) * 43758.5453);
}
float3 rand3(float2 x) {
    return frac(cos(mod(tofloat3(dot(x, tofloat2(13.9898, 8.141)),
							  dot(x, tofloat2(3.4562, 17.398)),
                              dot(x, tofloat2(13.254, 5.867))), tofloat3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(tofloat2(seed));
}
float3 rgb2hsv(float3 c) {
	float4 K = tofloat4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	float4 p = c.g < c.b ? tofloat4(c.bg, K.wz) : tofloat4(c.gb, K.xy);
	float4 q = c.r < p.x ? tofloat4(p.xyw, c.r) : tofloat4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return tofloat3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
float3 hsv2rgb(float3 c) {
	float4 K = tofloat4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float beehive_dist(float2 p){
	float2 s = tofloat2(1.0, 1.73205080757);
	p = abs(p);
	return max(dot(p, s*.5), p.x);
}
float4 beehive_center(float2 p) {
	float2 s = tofloat2(1.0, 1.73205080757);
	float4 hC = floor(tofloat4(p, p - tofloat2(.5, 1))/tofloat4(s,s)) + .5;
	float4 h = tofloat4(p - hC.xy*s, p - (hC.zw + .5)*s);
	return dot(h.xy, h.xy)<dot(h.zw, h.zw) ? tofloat4(h.xy, hC.xy) : tofloat4(h.zw, hC.zw + 9.73);
}
float3 fill_to_uv_stretch(float2 coord, float4 bb, float seed) {
	float2 uv_islands = frac(coord-bb.xy)/bb.zw;
	float random_value = rand(tofloat2(seed)+bb.xy+bb.zw);
	return tofloat3(uv_islands, random_value);
}
float3 fill_to_uv_square(float2 coord, float4 bb, float seed) {
	float2 uv_islands;
	if (bb.z > bb.w) {
		float2 adjusted_coord = coord + tofloat2(0.0, (bb.z - bb.w) / 2.0);
		uv_islands = frac(adjusted_coord-bb.xy)/bb.zz;
	} else {
		float2 adjusted_coord = coord + tofloat2((bb.w - bb.z) / 2.0, 0.0);
		uv_islands = frac(adjusted_coord-bb.xy)/bb.ww;
	}
	float random_value = rand(tofloat2(seed)+bb.xy+bb.zw);
	return tofloat3(uv_islands, random_value);
}
float2 get_from_tileset(float count, float seed, float2 uv) {
	return clamp((uv+floor(rand2(tofloat2(seed))*count))/count, tofloat2(0.0), tofloat2(1.0));
}
float2 custom_uv_transform(float2 uv, float2 cst_scale, float rnd_rotate, float rnd_scale, float2 seed) {
	seed = rand2(seed);
	uv -= tofloat2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = tofloat2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += tofloat2(0.5);
	return uv;
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(frac((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
float sd_box(float2 uv, float2 size) {
	float2 d = abs(uv)-size;
	return length(max(d, tofloat2(0)))+min(max(d.x, d.y), 0.0);
}
float3 blend_normal(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
float3 blend_dissolve(float2 uv, float3 c1, float3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
float3 blend_multiply(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
float3 blend_screen(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
float3 blend_overlay(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float3 blend_hard_light(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
float3 blend_soft_light(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
float3 blend_burn(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
float3 blend_dodge(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float3 blend_lighten(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
float3 blend_darken(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
float3 blend_difference(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*clamp(c2-c1, tofloat3(0.0), tofloat3(1.0)) + (1.0-opacity)*c2;
}
float3 blend_additive(float2 uv, float3 c1, float3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
float3 blend_addsub(float2 uv, float3 c1, float3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
float3 blend_linear_light(float2 uv, float3 c1, float3 c2, float opacity) {
return opacity*tofloat3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
float3 blend_vivid_light(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
float3 blend_pin_light(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_lerp_f(float c1, float c2) {
	return floor(c1 + c2);
}
float3 blend_hard_lerp(float2 uv, float3 c1, float3 c2, float opacity) {
		return opacity*tofloat3(blend_hard_lerp_f(c1.x, c2.x), blend_hard_lerp_f(c1.y, c2.y), blend_hard_lerp_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
float3 blend_exclusion(float2 uv, float3 c1, float3 c2, float opacity) {
	return opacity*tofloat3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
static const float p_o61681_amount1 = 1.000000000;
static const float p_o61681_amount2 = 0.720000000;
static const float p_o61681_amount3 = 1.000000000;
static const float p_o61681_amount4 = 1.000000000;
static const float p_o61681_amount5 = 1.000000000;
static const float p_o61682_value = 0.080000000;
static const float p_o61682_width = 0.210000000;
static const float p_o61682_contrast = 0.300000000;
static const float p_o61700_sx = 12.000000000;
static const float p_o61700_sy = 7.000000000;
static const float seed_o61685 = 0.000000000;
static const float p_o61685_sx = 1.000000000;
static const float p_o61685_sy = 1.000000000;
static const float p_o61685_rotate = 180.000000000;
static const float p_o61685_scale = 0.000000000;
static const float p_o61686_repeat = 1.000000000;
static const float p_o61686_gradient_0_pos = 0.000000000;
static const float4 p_o61686_gradient_0_col = tofloat4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
static const float p_o61686_gradient_1_pos = 1.000000000;
static const float4 p_o61686_gradient_1_col = tofloat4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
float4 o61686_gradient_gradient_fct(float x) {
  if (x < p_o61686_gradient_0_pos) {
    return p_o61686_gradient_0_col;
  } else if (x < p_o61686_gradient_1_pos) {
    return lerp(p_o61686_gradient_0_col, p_o61686_gradient_1_col, ((x-p_o61686_gradient_0_pos)/(p_o61686_gradient_1_pos-p_o61686_gradient_0_pos)));
  }
  return p_o61686_gradient_1_col;
}
float4 o61685_input_in(float2 uv, float _seed_variation_) {
float4 o61686_0_1_rgba = o61686_gradient_gradient_fct(frac(p_o61686_repeat*0.15915494309*hlsl_atan((uv).y-0.5, (uv).x-0.5)));
return o61686_0_1_rgba;
}
static const float seed_o61701 = 0.000000000;
static const float p_o61684_default_in1 = 0.000000000;
static const float p_o61684_default_in2 = 3.000000000;
static const float4 p_o61683_color = tofloat4(0.588235319, 0.913725495, 1.000000000, 1.000000000);
static const float p_o61707_default_in1 = 0.000000000;
static const float p_o61707_default_in2 = 0.000000000;
static const float p_o61705_bevel = 1.000000000;
static const float p_o61705_base = 1.000000000;
static const float p_o61704_w = 0.350000000;
static const float p_o61704_h = 0.350000000;
static const float p_o61704_cx = 0.000000000;
static const float p_o61704_cy = 0.000000000;

float4 _HexShieldColor;
float _HexShieldMultiper;
		
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			fixed4 frag (v2f i) : SV_Target {
				float _seed_variation_ = 0.0;
				float2 uv = i.uv;
float2 o61700_0_scale = tofloat2(p_o61700_sx * _HexShieldMultiper, p_o61700_sy*1.73205080757 * _HexShieldMultiper);
float2 o61700_0_uv = (uv)*o61700_0_scale;
float4 o61700_0_center = beehive_center(o61700_0_uv);float o61700_0_1_f = 1.0-2.0*beehive_dist(o61700_0_center.xy);
float o61682_0_step = clamp((o61700_0_1_f - (p_o61682_value))/max(0.0001, p_o61682_width)+0.5, 0.0, 1.0);
float o61682_0_false = clamp((min(o61682_0_step, 1.0-o61682_0_step) * 2.0) / (1.0 - p_o61682_contrast), 0.0, 1.0);
float o61682_0_true = 1.0-o61682_0_false;float o61682_0_1_f = o61682_0_false;
float4 o61700_1_2_fill = frac(round(16384.0*tofloat4(o61700_0_uv-o61700_0_center.xy-tofloat2(0.5, 0.57735026919), tofloat2(1.0, 1.15470053838))/o61700_0_scale.xyxy)/16384.0);
float4 o61701_0_bb = o61700_1_2_fill;float3 o61701_0_1_rgb = fill_to_uv_stretch((uv), o61701_0_bb, float((seed_o61701+frac(_seed_variation_))));
float3 o61685_0_map = o61701_0_1_rgb;
float o61685_0_rnd =  float((seed_o61685+frac(_seed_variation_)))+o61685_0_map.z;
float4 o61685_0_1_rgba = o61685_input_in(get_from_tileset(1.0, o61685_0_rnd, custom_uv_transform(o61685_0_map.xy, tofloat2(p_o61685_sx, p_o61685_sy), p_o61685_rotate*0.01745329251, p_o61685_scale, tofloat2(o61685_0_map.z, float((seed_o61685+frac(_seed_variation_)))))), false ? o61685_0_rnd : 0.0);
float o61702_0_1_f = (frac((dot((o61685_0_1_rgba).rgb, tofloat3(1.0))/3.0)-_Time.y*.5));
float2 o61699_0_c = frac(o61700_1_2_fill.xy+0.5*o61700_1_2_fill.zw);float o61699_0_1_f = length(o61699_0_c-tofloat2(0.5));
float o61703_0_1_f = (pow(frac(o61699_0_1_f-_Time.y*.5),8));
float o61684_0_clamp_false = o61703_0_1_f*p_o61684_default_in2;
float o61684_0_clamp_true = clamp(o61684_0_clamp_false, 0.0, 1.0);
float o61684_0_2_f = o61684_0_clamp_false;
float4 o61683_0_1_rgba = p_o61683_color;
float o61704_0_1_sdf2d = sd_box((uv)-tofloat2(p_o61704_cx+0.5, p_o61704_cy+0.5), tofloat2(p_o61704_w, p_o61704_h));
float o61705_0_1_f = clamp(p_o61705_base-o61704_0_1_sdf2d/max(p_o61705_bevel, 0.00001), 0.0, 1.0);
float4 o61706_0_1_rgba = tofloat4(tofloat3(1.0)-tofloat4(tofloat3(o61705_0_1_f), 1.0).rgb, tofloat4(tofloat3(o61705_0_1_f), 1.0).a);
float o61709_2_1_f = tofloat4(o61701_0_1_rgb, 1.0).b;
float o61708_0_1_f = (1.5+sin(o61709_2_1_f*5.+_Time.y*2.));
float o61707_0_clamp_false = (dot((o61706_0_1_rgba).rgb, tofloat3(1.0))/3.0)*o61708_0_1_f;
float o61707_0_clamp_true = clamp(o61707_0_clamp_false, 0.0, 1.0);
float o61707_0_1_f = o61707_0_clamp_false;
float4 o61681_0_b = tofloat4(tofloat3(o61682_0_1_f), 1.0);
float4 o61681_0_l;
float o61681_0_a;

o61681_0_l = tofloat4(tofloat3(o61702_0_1_f), 1.0);
o61681_0_a = p_o61681_amount1*1.0;
o61681_0_b = tofloat4(blend_multiply((uv), o61681_0_l.rgb, o61681_0_b.rgb, o61681_0_a*o61681_0_l.a), min(1.0, o61681_0_b.a+o61681_0_a*o61681_0_l.a));

o61681_0_l = tofloat4(tofloat3(o61684_0_2_f), 1.0);
o61681_0_a = p_o61681_amount2*1.0;
o61681_0_b = tofloat4(blend_multiply((uv), o61681_0_l.rgb, o61681_0_b.rgb, o61681_0_a*o61681_0_l.a), min(1.0, o61681_0_b.a+o61681_0_a*o61681_0_l.a));

o61681_0_l = tofloat4(tofloat3(o61703_0_1_f), 1.0);
o61681_0_a = p_o61681_amount3*1.0;
o61681_0_b = tofloat4(blend_additive((uv), o61681_0_l.rgb, o61681_0_b.rgb, o61681_0_a*o61681_0_l.a), min(1.0, o61681_0_b.a+o61681_0_a*o61681_0_l.a));

o61681_0_l = o61683_0_1_rgba;
o61681_0_a = p_o61681_amount4*1.0;
o61681_0_b = tofloat4(blend_multiply((uv), o61681_0_l.rgb, o61681_0_b.rgb, o61681_0_a*o61681_0_l.a), min(1.0, o61681_0_b.a+o61681_0_a*o61681_0_l.a));

o61681_0_l = o61683_0_1_rgba;
o61681_0_a = p_o61681_amount5*o61707_0_1_f;
o61681_0_b = tofloat4(blend_additive((uv), o61681_0_l.rgb, o61681_0_b.rgb, o61681_0_a*o61681_0_l.a), min(1.0, o61681_0_b.a+o61681_0_a*o61681_0_l.a));

float4 o61681_0_2_rgba = o61681_0_b;

				// sample the generated texture
				fixed4 col = o61681_0_2_rgba;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				return fixed4(col.rgb * _HexShieldColor.rgb, col.r);
			}
			ENDCG
		}
	}
}



