Shader "Unlit/DefinitiveSDF"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define MAX_STEPS 100
            #define MAX_DIST 100.
            #define SURF_DIST .01

            uniform int _QtdObj;
            uniform float _ObjectTypes [20];
            uniform float4 _Positions [20];
            uniform float4 _Translations [20];
            uniform float4 _Scales [20];
            uniform float4 _Colors [20];
            uniform float4 _Operations [20];

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            float3x3 setCamera(float3 ro, float3 lookat, float3 wUp){

                float3 f = normalize(lookat - ro);
                float3 r = normalize(cross(float3(0., 1., 0.), f));
                float3 u = normalize(cross(f, r));
                
                return (float3x3(f,r,u));
            }

            float sdPlane( float3 p )
            {
                return p.y;
            }

            float sdSphere( float3 p, float s )
            {
                return length(p)-s;
            }

            float sdCapsule(float3 p, float3 a, float3 b, float r) {
                float3 ab = b-a;
                float3 ap = p-a;
                
                float t = dot(ab, ap) / dot(ab, ab);
                t = clamp(t, 0., 1.);
                
                float3 c = a + t*ab;
                
                return length(p-c)-r;
            }

            float sdTorus(float3 p, float2 r) {

                float x = length(p.xz)-r.x;
                return length(float2(x, p.y))-r.y;
            }

            float dBox(float3 p, float3 s) {
                return length(max(abs(p)-s, 0.));
            }

            float sdCylinder(float3 p, float3 a, float3 b, float r) {
                float3 ab = b-a;
                float3 ap = p-a;
                
                float t = dot(ab, ap) / dot(ab, ab);
                //t = clamp(t, 0., 1.);
                
                float3 c = a + t*ab;
                
                float x = length(p-c)-r;
                float y = (abs(t-.5)-.5)*length(ab);
                float e = length(max(float2(x, y), 0.));
                float i = min(max(x, y), 0.);
                
                return e+i;
            }

            float2 getDist(float3 p){

                // float t = iTime;
                float4 sphere[20];
                float sphereDist[20];

                float4 box[20];
                float4 boxDist[20];

                float4 capsule[20];
                float4 capsuleDist[20];

                float4 torus[20];
                float4 torusDist[20];

                float4 cylinder[20];
                float4 cylinderDist[20];

                float dist = MAX_DIST;

                for(int i = 0; i < _QtdObj; i++){

                    if(_ObjectTypes[i] == 0){ // Sphere

                        sphere[i] = float4(_Positions[i]);
                        sphereDist[i] = sdSphere(p-sphere[i].xyz, sphere[i].w);

                        dist = min(dist, sphereDist[i]);
                    }
                    else if(_ObjectTypes[i] == 1){ // Box

                        box[i] = float4(_Positions[i]);
                        boxDist[i] = dBox(p - box[i].xyz, float3(1,1, 1)*box[i].w);

                        dist = min(dist, boxDist[i]);
                    } 
                    else if(_ObjectTypes[i] == 2){  // Capsule

                        capsule[i] = float4(_Positions[i]);
                        capsuleDist[i] = sdCapsule(p, capsule[i].xyz, float3(capsule[i].x, capsule[i].y + 2.0, capsule[i].z), capsule[i].w);

                        dist = min(dist, capsuleDist[i]);
                    } 
                    else if(_ObjectTypes[i] == 3){ // Torus

                        torus[i] = float4(_Positions[i]);
                        torusDist[i] = sdTorus(p - torus[i].xyz, float2(1.5, .4)*torus[i].w);

                        dist = min(dist, torusDist[i]);
                    }

                    else if(_ObjectTypes[i] == 4){ // Cylinder

                        cylinder[i] = float4(_Positions[i]);
                        cylinderDist[i] = sdCylinder(p, cylinder[i].xyz, float3(cylinder[i].x + 3.0, cylinder[i].y, cylinder[i].z), cylinder[i].w);

                        dist = min(dist, cylinderDist[i]);
                    }
                }

                float groundDist = sdPlane(p);

                return min(dist, groundDist);
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

            fixed4 frag (Interpolators interpolator) : SV_Target
            {
                float2 uv = interpolator.uv;
                uv -= .5;
                uv.x *= 640/360 * 1.75; // numero cabalistico


                float3 ro = float3(.0, 2.0, -2.);
                float3 lookat = float3(.0, 1., 5.);

                float3x3 cameraMatrix = setCamera(ro, lookat, float3(0., 1., 0.));
                float zoom = 1.;

                float3 c = ro + cameraMatrix[0]*zoom;
                float3 i = c + uv.x * cameraMatrix[1] + uv.y * cameraMatrix[2];
                float3 rd = i - ro;

                float res = rayMarch(ro, rd);
                res /= 20.;

                float alpha = res;
                float4 col = float4(alpha, alpha, alpha, 1.0); 

                return col;
                
                //// DEBUG ////
                //return _Positions[1];
                //return float4(_QtdObj-1.5, 0, 0, 1.0);
                //return float4(uv, 0, 1.0);
            }
            ENDCG
        }
    }
}
