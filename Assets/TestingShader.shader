Shader "Unlit/TestingShader"
{

    Properties
    {
        _Color ("Color", Color) = (0,0,0,1)
        _BallPosition ("BallPosition", Vector) = (0,0,0,1)

    }

    SubShader
    {
        //Tags{ "RenderType"="Opaque" "Queue"="Opaque" }
        Tags{ "Queue"="Transparent" "RenderType"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off
        //Blend 1 Off
        //Blend One One
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            float4 _BallPosition;
            float4 _Color;

            #include "UnityCG.cginc"
            #define MAX_STEPS 100
            #define MAX_DIST 100.
            #define SURF_DIST .01

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

            float sdPlane( float3 p )
            {
                return p.y;
            }

            float sdSphere( float3 p, float s )
            {
                return length(p)-s;
            }

            float2 getDist(float3 p){

                // float t = iTime;

                float4 sphere = _BallPosition; //float4(0., 1., 5., 1.); 
                float4 sphere2 = float4(.5, 3., 2., 2.);
                float4 wall = float4(0.0, .0, 2, 1.0);
                
                float sphereDist = sdSphere((p-sphere.xyz), sphere.w);
                float sphereDist2 = sdSphere((p-sphere2.xyz), sphere2.w);
                float groundDist = sdPlane(p);
                
                return float2(sphereDist, 1.);

                // if(sphereDist < groundDist)
                //     return float2(sphereDist, 1.);
                
                // else return float2(groundDist, 0.);
            }

            float rayMarch(float3 ro, float3 rd){

                float dO = .0;
                
                for(int i = 0; i < MAX_STEPS; i++){
                    
                    float3 p = ro + rd * dO; // distancia da superficie
                    float dS = getDist(p).x;
                    dO = dO + dS;
                    
                    if(dO > MAX_DIST || dS < SURF_DIST) break;
                }
                
                return dO;
            }

            float3x3 setCamera(float3 ro, float3 lookat, float3 wUp){

                float3 f = normalize(lookat - ro);
                float3 r = normalize(cross(float3(0., 1., 0.), f));
                float3 u = normalize(cross(f, r));
                
                return (float3x3(f,r,u));
            }

            fixed4 frag (Interpolators interpolator) : SV_Target
            {
                // Normalized pixel coordinates (from 0 to 1)
                // vec2 uv = fragCoord/iResolution.xy; // 640 x 360

                float2 uv = interpolator.uv;
                uv -= .5;
                uv.x *= 640/360 * 1.75; // numero cabalistico

                // float3 worldPos = UnityWorldSpaceViewDir(float3(.0, .0, .0));

                float3 ro = _WorldSpaceCameraPos; //float3(.0, 1.0, -2.);
                float3 lookat = float3(.0, 1., 5.);

                float3x3 cameraMatrix = setCamera(ro, lookat, float3(0., 1., 0.));
                float zoom = 1.;

                float3 c = ro + cameraMatrix[0]*zoom;
                float3 i = c + uv.x * cameraMatrix[1] + uv.y * cameraMatrix[2];
                float3 rd = i - ro;//i - ro;

                float res = rayMarch(ro, rd);
                res /= 20.;

                //res = smoothstep(.001 , 1. , res);

                res = step(res, 0.5);
                //float alpha = step(0.5, res); // Se res < 0.5, alpha é 0; se res >= 0.5, alpha
                
                float3 col = float3(res, res, res);
                // if(res = 1.0)
                //     return float4(col, 0.0);

                if (res == 0.0) {
                        // If color is zero, use blending
                    fixed4 col = float4(res, res, res, 0.0); // Adjust the alpha value as needed
                    return col*_Color;
                } else {
                    // If color is not zero, don't blend (use alpha = 1.0)
                    fixed4 col = float4(res, res, res, 1.0);
                    return col*_Color;
                }
            }
            ENDCG
        }
    }
}
