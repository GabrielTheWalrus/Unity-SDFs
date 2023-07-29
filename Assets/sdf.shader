Shader "Unlit/sdf"
{
    Properties{

        _Color ("Color", Color) = (0,0,0,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            float4 _Color;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            // fixed4 frag (Interpolators i) : SV_Target
            // {

            //     // float dist = distance(float2(0,0), i.uv * 2 - 1) - 0.4;
            //     // float dist2 = distance(float2(0,0), i.uv * 2 - 0.25) - 0.4;

            //     // clip(dist2);
            //     // //clip(dist);

            //     // return dist2 * _Color;

            //     float dist = distance(float2(0,0), i.uv * 2 - 1) - 0.4;
            //     float dist2 = distance(float2(0,0), i.uv.x - 0.25) - 0.4;
            //     float dist3 = min(dist, dist2);

            //     clip(-dist3);

            //     return dist3.xxxx;

                
            // }

            fixed4 frag (Interpolators i) : SV_Target
            {

                float circle = distance(float2(0,0), i.uv * 2 - 1) - 0.3;
                float sky = distance(float2(0,0), i.uv.y - 1) - 0.4;
                //float circle2 = distance(float2(0,0), i.uv * 4 - 1) - 0.5;
                float circle2 = distance(float2(0,0), i.uv.y - 1) - 1.5;

                float circle_sky_combination = min(circle, sky);
                float full_scene = min(circle_sky_combination, circle2);

                clip(-full_scene);

                float4 teste = step(0, -lerp(full_scene, sky, 1)) * float4(1, 0, 1, 1);
                float4 teste2 = step(0, -lerp(full_scene, circle, 1))* float4(1, 0.92, 0.016, 1);
                float4 teste3 = step(0, -lerp(full_scene, circle2, 1))* float4(1, 0, 0, 1);
                
                float4 t = teste + teste2 + teste3;

                return t;

            }

            ENDCG
        }
    }
}

/*

float circle = distance(float2(0,0), i.uv * 2 - 1) - 0.3;
                float sky = distance(float2(0,0), i.uv.y - 1) - 0.4;

clip(-sky);
clip(-circle);

//return lerp(circle, float4(1, 0.92, 0.016, 1), 1);

return lerp(sky, float4(0, 0, 1, 1), 1);

*/
