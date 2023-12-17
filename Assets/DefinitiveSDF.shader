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
            uniform int _QtdOperations;
            uniform float _ObjectTypes [20];
            uniform float4 _Positions [20];
            uniform float4 _Rotations [20];
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

            float3 Translate(float3 pos, float3 translation)
            {
                return pos + translation;
            }

            float3 RotateVector(float3 vec, float3 axis, float angle)
            {
                axis = normalize(axis);

                float3 crossProduct = cross(vec, axis);
                float dotProduct = dot(vec, axis);
                float3 rotatedVector = vec * cos(angle) + crossProduct * sin(angle) + axis * dotProduct * (1 - cos(angle));

                return rotatedVector;
            }

            float3 Scale(float3 pos, float3 scale)
            {
                return pos * scale;
            }

            float sdPlane( float3 p )
            {
                return p.y;
            }

            float sdSphere(float3 p, float radius, float4 rotation, float4 scale)
            {
                p = RotateVector(p, rotation.xyz, rotation.w);
                p = p / scale.xyz;

                return length(p) - (radius * scale);
            }

            float dBox(float3 p, float4 rotation, float4 scale)
            {
                p = RotateVector(p, rotation.xyz, rotation.w);

                return length(max(abs(p) - scale.xyz, 0.));
            }

            float sdCapsule(float3 p, float3 capsuleCenterPosition, float r, float4 rotation, float4 scale)
            {
                float3 a = float3(capsuleCenterPosition.x, capsuleCenterPosition.y + 1.0, capsuleCenterPosition.z);
                float3 b = float3(capsuleCenterPosition.x, capsuleCenterPosition.y - 1.0, capsuleCenterPosition.z);
                float3 ab = b - a;

                ab = RotateVector(ab.xyz, rotation.xyz, rotation.w);
                ab *= scale.y;

                float3 ap = p - a;

                float t = dot(ab, ap) / dot(ab, ab);
                t = clamp(t, 0., 1.);

                float3 c = a + t * ab;

                return length(p - c) - (r * (scale.x + scale.z));
            }

            float sdTorus(float3 p, float2 r, float4 rotation, float4 scale)
            {
                p = RotateVector(p, rotation.xyz, rotation.w);
                p = p / scale.xyz;

                float x = length(p.xz) - r.x;
                return length(float2(x, p.y)) - r.y;
            }

            float sdCylinder(float3 p, float3 capsuleCenterPosition, float r, float4 rotation, float4 scale) {

                float3 a = float3(capsuleCenterPosition.x, capsuleCenterPosition.y + 1.0, capsuleCenterPosition.z);
                float3 b = float3(capsuleCenterPosition.x, capsuleCenterPosition.y - 1.0, capsuleCenterPosition.z);
                float3 ab = b - a;

                ab = RotateVector(ab.xyz, rotation.xyz, rotation.w);
                ab *= scale.y;

                float3 ap = p-a;
                
                float t = dot(ab, ap) / dot(ab, ab);

                float3 c = a + t * ab;
                
                float x = length(p-c) - (r * (scale.x + scale.z));
                float y = (abs(t-.5)-.5)*length(ab);
                float e = length(max(float2(x, y), 0.));
                float i = min(max(x, y), 0.);
                
                return e+i;
            }

            float2 resolveOperator(float2 dist, float2 dist2, float i){

                float2 res;
                if(i == 0){
                    if(dist.x < dist2.x){
                        res.x = dist.x;
                        res.y = dist.y;
                    }
                    else{
                        res.x = dist2.x;
                        res.y = dist2.y;
                    }
                }
                else if(i == 1){
                    if(dist.x > dist2.x){
                        res.x = dist.x;
                        res.y = dist.y;
                    }
                    else{
                        res.x = dist2.x;
                        res.y = dist2.y;
                    }
                }
                else if(i == 2){

                    if(-dist.x > dist2.x){
                        res.x = -dist.x;
                        res.y = dist.y;
                    }
                    else{
                        res.x = dist2.x;
                        res.y = dist2.y;
                    }
                }

                return res;
            }

            float2 getDist(float3 p){

                float4 sphere[20];
                float sphereDist[20];

                float4 box[20];
                float boxDist[20];

                float4 capsule[20];
                float capsuleDist[20];

                float4 torus[20];
                float torusDist[20];

                float4 cylinder[20];
                float cylinderDist[20];

                float dist = MAX_DIST;
                float object_id = -1;

                float groundDist = sdPlane(p);

                float2 distance_res[20];

                for(int k = 0; k < 20; k++){
                    distance_res[k].x = MAX_DIST;
                    distance_res[k].y = -1;
                }
                
                for(int i = 0; i < _QtdObj; i++){

                    if(_ObjectTypes[i] == 0) // Sphere
                    {
                        sphere[i] = _Positions[i];
                        sphereDist[i] = sdSphere(p - sphere[i].xyz, sphere[i].w, _Rotations[i], _Scales[i]);
                        distance_res[i] = float2(min(distance_res[i].x, sphereDist[i]), i);                 
                    }
                    else if(_ObjectTypes[i] == 1) // Box
                    {
                        box[i] = _Positions[i];
                        boxDist[i] = dBox(p - box[i].xyz, _Rotations[i], _Scales[i]);
                        distance_res[i] = float2(min(distance_res[i].x, boxDist[i]), i);
                    } 
                    else if(_ObjectTypes[i] == 2)  // Capsule
                    {
                        capsule[i] = _Positions[i];
                        capsuleDist[i] = sdCapsule(p, capsule[i].xyz, capsule[i].w, _Rotations[i], _Scales[i]);
                        distance_res[i] = float2(min(distance_res[i].x, capsuleDist[i]), i);
                    } 
                    else if(_ObjectTypes[i] == 3) // Torus
                    {
                        torus[i] = _Positions[i];
                        torusDist[i] = sdTorus(p - torus[i].xyz, float2(1.5, .4) * torus[i].w, _Rotations[i], _Scales[i]);
                        distance_res[i] = float2(min(distance_res[i].x, torusDist[i]), i);
                    }
                    else if(_ObjectTypes[i] == 4) // Cylinder
                    {
                        cylinder[i] = _Positions[i];
                        cylinderDist[i] = sdCylinder(p, cylinder[i].xyz, cylinder[i].w, _Rotations[i], _Scales[i]);
                        distance_res[i] = float2(min(distance_res[i].x, cylinderDist[i]), i);
                    }
                }

                int index_obj_1;
                int index_obj_2;
                float operation;
                float _color = -1;
                float2 result = float2(MAX_DIST, -1);  
                int index_to_ignore[20];

                for(int j = 0; j < 20; j++)
                    index_to_ignore[j] = 0;

                for(int x = 0; x < _QtdObj; x++){

                    if(x < _QtdOperations){
                        index_obj_1 = _Operations[x].x;
                        index_obj_2 = _Operations[x].y;
                        operation = _Operations[x].z;

                        float2 res2 = resolveOperator(distance_res[index_obj_1], distance_res[index_obj_2], operation);

                        if(res2.x < result.x){
                            result = res2;
                        }

                        index_to_ignore[index_obj_1] = 1;
                        index_to_ignore[index_obj_2] = 1;
                    }
                    else{
                        if(index_to_ignore[x] == 0)
                            if(distance_res[x].x < result.x)
                                result = distance_res[x];
                    }

                    dist = result.x;
                    _color = result.y;
                    
                }

                if(dist < groundDist)
                    return float2(dist, _color);
                else
                    return float2(groundDist, -1);

            }

            float4 rayMarch(float3 ro, float3 rd){

                float dO = .0;
                float object_id;
                float2 distance;

                for(int i = 0; i < MAX_STEPS; i++){

                    float3 p = ro + rd * dO; // distancia da superficie
                    distance = getDist(p);
                    float dS = distance.x;
                    object_id = distance.y;

                    dO = dO + dS;

                    if(dO > MAX_DIST || dS < SURF_DIST) break;

                }

                if(object_id == -1)
                    return float4(dO, float3(1,1,1));
                else
                    return float4(dO, _Colors[object_id].xyz);
            }

            float3 getNormal(float3 p){
 
                float d = getDist(p).x;
                float2 e = float2(.00001, 0);

                float3 n = d - float3(
                    getDist(p-e.xyy).x,
                    getDist(p-e.yxy).x,
                    getDist(p-e.yyx).x);

                return normalize(n);
            }

            float getLight(float3 p, float3 lightSourcePos){

                float3 l = normalize(lightSourcePos-p); // light direction from point p
                float3 n = getNormal(p);

                float dif = clamp(dot(n,l), 0., 1.);

                float d = rayMarch(p+n*SURF_DIST*2.0, l).x;

                if(d < length(lightSourcePos-p))
                    return dif*0.2;

                return dif;

            }

            float2x2 Rot(float a) {
                float s = sin(a);
                float c = cos(a);
                return float2x2(c, -s, s, c);
            }

            fixed4 frag (Interpolators interpolator) : SV_Target
            {
                float2 uv = interpolator.uv;
                
                uv -= .5;
                uv.x *= 640/360 * 1.75;
                float t = _Time * 25;

                float pi = 3.1415926;
                float3 ro = float3(0, 5.0, -5);
                
                float3 lookat = float3(.0, 1., 5.);

                float3x3 cameraMatrix = setCamera(ro, lookat, float3(0., 1., 0.));

                float zoom = 1.;

                float3 c = ro + cameraMatrix[0]*zoom;
                float3 i = c + uv.x * cameraMatrix[1] + uv.y * cameraMatrix[2];
                float3 rd = i - ro;

                float3 lightSourcePos = float3(6, 6., 3);
                
                float4 res = rayMarch(ro, rd);
                
                float3 p = ro + rd * res.x;

                float4 res_light = getLight(p, lightSourcePos);
                float4 res_color = float4(res.yzw, 1);
                
                return res_light * res_color;
            }
            ENDCG
        }
    }
}
