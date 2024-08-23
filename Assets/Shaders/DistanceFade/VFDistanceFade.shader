/// Thanks to Ronja Böhringer made some of this code

Shader "Custom/VFDistanceFade"
{
    //show values to edit in inspector
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [NoScaleOffset]_DitherPattern ("Dithering Pattern", 2D) = "white" {}
        _MinDistance ("Minimum Fade Distance", Float) = 0
        _MaxDistance ("Maximum Fade Distance", Float) = 1
    }

    SubShader {
        //the material is completely non-transparent and is rendered at the same time as the other opaque geometry
        Tags{ "RenderType"="Transparent" "Queue"="Transparent"}

        Blend SrcAlpha OneMinusSrcAlpha

        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets\Cginc\DistanceFade.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD1;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _DitherPattern;
            float4 _DitherPattern_TexelSize;

            float4 _Color;

            //remapping of distance
            float _MinDistance;
            float _MaxDistance;

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.pos);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 color = tex2D(_MainTex, i.uv);

                float distanceFade = DistanceFadeClip(i.screenPos, _DitherPattern, _DitherPattern_TexelSize, _MinDistance, _MaxDistance);

                //clip(DistanceFadeClip(i.screenPos, _DitherPattern, _DitherPattern_TexelSize, _MinDistance, _MaxDistance));

                return fixed4( color.rgb, distanceFade > 0 ? color.a : .5f);

            }
            ENDCG
        }
    }
}
