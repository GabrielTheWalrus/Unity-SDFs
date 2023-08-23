Shader "Unlit/SDF3d"
{
    Properties
    {
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

            float2 map( float3 pos )
            {
                float2 res = float2( pos.y, 0.0 );

                // bounding box
                // if( sdBox( pos-vec3(-2.0,0.3,0.25),vec3(0.3,0.3,1.0) )<res.x )
                // {
                // res = opU( res, vec2( sdSphere(    pos-vec3(-2.0,0.25, 0.0), 0.25 ), 26.9 ) );
                // res = opU( res, vec2( sdRhombus(  (pos-vec3(-2.0,0.25, 1.0)).xzy, 0.15, 0.25, 0.04, 0.08 ),17.0 ) );
                // }

                // bounding box
                // if( sdBox( pos-vec3(0.0,0.3,-1.0),vec3(0.35,0.3,2.5) )<res.x )
                // {
                // res = opU( res, vec2( sdCappedTorus((pos-vec3( 0.0,0.30, 1.0))*vec3(1,-1,1), vec2(0.866025,-0.5), 0.25, 0.05), 25.0) );
                // res = opU( res, vec2( sdBoxFrame(    pos-vec3( 0.0,0.25, 0.0), vec3(0.3,0.25,0.2), 0.025 ), 16.9 ) );
                // res = opU( res, vec2( sdCone(        pos-vec3( 0.0,0.45,-1.0), vec2(0.6,0.8),0.45 ), 55.0 ) );
                // res = opU( res, vec2( sdCappedCone(  pos-vec3( 0.0,0.25,-2.0), 0.25, 0.25, 0.1 ), 13.67 ) );
                // res = opU( res, vec2( sdSolidAngle(  pos-vec3( 0.0,0.00,-3.0), vec2(3,4)/5.0, 0.4 ), 49.13 ) );
                // }

                // bounding box
                // if( sdBox( pos-vec3(1.0,0.3,-1.0),vec3(0.35,0.3,2.5) )<res.x )
                // {
                // res = opU( res, vec2( sdTorus(      (pos-vec3( 1.0,0.30, 1.0)).xzy, vec2(0.25,0.05) ), 7.1 ) );
                // res = opU( res, vec2( sdBox(         pos-vec3( 1.0,0.25, 0.0), vec3(0.3,0.25,0.1) ), 3.0 ) );
                // res = opU( res, vec2( sdCapsule(     pos-vec3( 1.0,0.00,-1.0),vec3(-0.1,0.1,-0.1), vec3(0.2,0.4,0.2), 0.1  ), 31.9 ) );
                // res = opU( res, vec2( sdCylinder(    pos-vec3( 1.0,0.25,-2.0), vec2(0.15,0.25) ), 8.0 ) );
                // res = opU( res, vec2( sdHexPrism(    pos-vec3( 1.0,0.2,-3.0), vec2(0.2,0.05) ), 18.4 ) );
                // }

                // bounding box
                // if( sdBox( pos-vec3(-1.0,0.35,-1.0),vec3(0.35,0.35,2.5))<res.x )
                // {
                // res = opU( res, vec2( sdPyramid(    pos-vec3(-1.0,-0.6,-3.0), 1.0 ), 13.56 ) );
                // res = opU( res, vec2( sdOctahedron( pos-vec3(-1.0,0.15,-2.0), 0.35 ), 23.56 ) );
                // res = opU( res, vec2( sdTriPrism(   pos-vec3(-1.0,0.15,-1.0), vec2(0.3,0.05) ),43.5 ) );
                // res = opU( res, vec2( sdEllipsoid(  pos-vec3(-1.0,0.25, 0.0), vec3(0.2, 0.25, 0.05) ), 43.17 ) );
                // res = opU( res, vec2( sdHorseshoe(  pos-vec3(-1.0,0.25, 1.0), vec2(cos(1.3),sin(1.3)), 0.2, 0.3, vec2(0.03,0.08) ), 11.5 ) );
                // }

                // bounding box
                // if( sdBox( pos-vec3(2.0,0.3,-1.0),vec3(0.35,0.3,2.5) )<res.x )
                // {
                // res = opU( res, vec2( sdOctogonPrism(pos-vec3( 2.0,0.2,-3.0), 0.2, 0.05), 51.8 ) );
                // res = opU( res, vec2( sdCylinder(    pos-vec3( 2.0,0.14,-2.0), vec3(0.1,-0.1,0.0), vec3(-0.2,0.35,0.1), 0.08), 31.2 ) );
                // res = opU( res, vec2( sdCappedCone(  pos-vec3( 2.0,0.09,-1.0), vec3(0.1,0.0,0.0), vec3(-0.2,0.40,0.1), 0.15, 0.05), 46.1 ) );
                // res = opU( res, vec2( sdRoundCone(   pos-vec3( 2.0,0.15, 0.0), vec3(0.1,0.0,0.0), vec3(-0.1,0.35,0.1), 0.15, 0.05), 51.7 ) );
                // res = opU( res, vec2( sdRoundCone(   pos-vec3( 2.0,0.20, 1.0), 0.2, 0.1, 0.3 ), 37.0 ) );
                // }
                
                return res;
            }


            // funções do shader
            float3x3 setCamera( float3 ro, float3 ta )
            {
                float3 cw = normalize(ta-ro);
                float3 cp = float3(0.0, 1.0, 0.0);
                float3 cu = normalize( cross(cw,cp) );
                float3 cv =          ( cross(cu,cw) );

                // unity trabalha com matriz em formato diferente
                return transpose(float3x3( cu, cv, cw ));
            }

            // https://iquilezles.org/articles/boxfunctions
            float2 iBox( float3 ro, float3 rd, float3 rad ) 
            {
                float3 m = 1.0/rd;
                float3 n = m*ro;
                float3 k = abs(m)*rad;
                float3 t1 = -n - k;
                float3 t2 = -n + k;
                return float2( max( max( t1.x, t1.y ), t1.z ),
                            min( min( t2.x, t2.y ), t2.z ) );
            }

            float2 raycast( float3 ro, float3 rd )
            {
                float2 res = float2(-1.0,-1.0);

                float tmin = 1.0;
                float tmax = 20.0;

                // raytrace floor plane
                float tp1 = (0.0-ro.y)/rd.y;
                if( tp1>0.0 )
                {
                    tmax = min( tmax, tp1 );
                    res = float2( tp1, 1.0 );
                }
                //else return res;
                
                // raymarch primitives   
                float2 tb = iBox( ro-float3(0.0,0.4,-0.5), rd, float3(2.5,0.41,3.0) );
                if( tb.x<tb.y && tb.y>0.0 && tb.x<tmax)
                {
                    //return vec2(tb.x,2.0);
                    tmin = max(tb.x,tmin);
                    tmax = min(tb.y,tmax);

                    float t = tmin;
                    for( int i=0; i<70 && t<tmax; i++ )
                    {
                        float2 h = map( ro+rd*t );
                        if( abs(h.x)<(0.0001*t) )
                        { 
                            res = float2(t,h.y); 
                            break;
                        }
                        t += h.x;
                    }
                }
                
                return res;
            }

            float3 calcNormal(float3 pos)
            {
                float3 normal;

                if (true) 
                {
                    float2 e = float2(1.0, -1.0) * 0.5773 * 0.0005;

                    normal = normalize(e.xyy * map(pos + e.xyy).x +
                                    e.yyx * map(pos + e.yyx).x +
                                    e.yxy * map(pos + e.yxy).x +
                                    e.xxx * map(pos + e.xxx).x);
                } 
                else 
                {
                    // inspired by tdhooper and klems - a way to prevent the compiler from inlining map() 4 times
                    normal = float3(0.0,0.0,0.0);
                    for (int i = 0; i < 4; i++) 
                    {
                        float3 e = 0.5773 * (2.0 * float3((((i + 3) >> 1) & 1), ((i >> 1) & 1), (i & 1)) - 1.0);
                        normal += e * map(pos + 0.0005 * e).x;
                    }
                    normal = normalize(normal);
                }

                return normal;
            }

            // https://iquilezles.org/articles/checkerfiltering
            float checkersGradBox( float2 p, float2 dpdx, float2 dpdy )
            {
                // filter kernel
                float2 w = abs(dpdx)+abs(dpdy) + 0.001;

                // analytical integral (box filter)
                float2 i = 2.0*(abs(frac((p-0.5*w)*0.5)-0.5)-abs(frac((p+0.5*w)*0.5)-0.5))/w;
                // xor pattern
                return 0.5 - 0.5*i.x*i.y;                  
            }


            float3 render( float3 ro, float3 rd, float3 rdx, float3 rdy )
            { 
                // background
                float3 col = float3(0.7, 0.7, 0.9) - max(rd.y,0.0)*0.3;
                
                // raycast scene
                float2 res = raycast(ro,rd);
                float t = res.x;
                float m = res.y;
                if( m>-0.5 )
                {
                    float3 pos = ro + t*rd;
                    float3 nor = (m<1.5) ? float3(0.0,1.0,0.0) : calcNormal( pos );
                    float3 ref = reflect( rd, nor );
                    
                    // material        
                    col = 0.2 + 0.2*sin( m*2.0 + float3(0.0,1.0,2.0) );
                    float ks = 1.0;
                    /*
                    if( m<1.5 )
                    {
                        // project pixel footprint into the plane
                        float3 dpdx = ro.y*(rd/rd.y-rdx/rdx.y);
                        float3 dpdy = ro.y*(rd/rd.y-rdy/rdy.y);

                        float f = checkersGradBox( 3.0*pos.xz, 3.0*dpdx.xz, 3.0*dpdy.xz );
                        col = 0.15 + f*float3(0.05, 0.05, 0.05);
                        ks = 0.4;
                    }

                    // lighting
                    float occ = calcAO( pos, nor );
                    
                    vec3 lin = vec3(0.0);

                    // sun
                    {
                        vec3  lig = normalize( vec3(-0.5, 0.4, -0.6) );
                        vec3  hal = normalize( lig-rd );
                        float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
                    //if( dif>0.0001 )
                            //dif *= calcSoftshadow( pos, lig, 0.02, 2.5 );
                        float spe = pow( clamp( dot( nor, hal ), 0.0, 1.0 ),16.0);
                            spe *= dif;
                            spe *= 0.04+0.96*pow(clamp(1.0-dot(hal,lig),0.0,1.0),5.0);
                            //spe *= 0.04+0.96*pow(clamp(1.0-sqrt(0.5*(1.0-dot(rd,lig))),0.0,1.0),5.0);
                        lin += col*2.20*dif*vec3(1.30,1.00,0.70);
                        lin +=     5.00*spe*vec3(1.30,1.00,0.70)*ks;
                    }
                    // sky
                    {
                        float dif = sqrt(clamp( 0.5+0.5*nor.y, 0.0, 1.0 ));
                            dif *= occ;
                        float spe = smoothstep( -0.2, 0.2, ref.y );
                            spe *= dif;
                            spe *= 0.04+0.96*pow(clamp(1.0+dot(nor,rd),0.0,1.0), 5.0 );
                    //if( spe>0.001 )
                            //spe *= calcSoftshadow( pos, ref, 0.02, 2.5 );
                        lin += col*0.60*dif*vec3(0.40,0.60,1.15);
                        lin +=     2.00*spe*vec3(0.40,0.60,1.30)*ks;
                    }
                    // back
                    {
                        float dif = clamp( dot( nor, normalize(vec3(0.5,0.0,0.6))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
                            dif *= occ;
                        lin += col*0.55*dif*vec3(0.25,0.25,0.25);
                    }
                    // sss
                    {
                        float dif = pow(clamp(1.0+dot(nor,rd),0.0,1.0),2.0);
                            dif *= occ;
                        lin += col*0.25*dif*vec3(1.00,1.00,1.00);
                    }
                    
                    col = lin;

                    col = mix( col, vec3(0.7,0.7,0.9), 1.0-exp( -0.0001*t*t*t ) );*/
                }

                return float3( clamp(col,0.0,1.0) );
            }

            fixed4 frag (Interpolators i) : SV_Target
            {

                float time =  32.0 + _Time.y * 5.0;

                // camera
                float3 ta = float3( 0.25, -0.75, -0.75 ); // point
                // float3 ro = ta + float3( 0.0, 3, 5 ); // eye

                float3 ro = ta + float3( 4.5*cos(0.1*time + 7.0*1), 2.2, 4.5*sin(0.1*time + 7.0*1) );

                // camera-to-world transformation
                float3x3 ca = setCamera( ro, ta );
                float3 total = float3(0.0, 0.0, 0.0);

                float2 resolution = float2(1000.0, 1000.0);
                float2 fragCood = i.uv * resolution.xy;

                float2 p = i.uv * 2.0 - 1;
                
                //float2 p = (2.0 * fragCood-resolution.xy)/resolution.y;

                // focal length
                float fl = 2.5;
                
                // ray direction
                float3 rd = mul(ca, normalize( float3(p,fl) ));

                // ray differentials
                float2 px = p + float2(0.001, 0.0);
                float2 py = p + float2(0.0, 0.001);
                float3 rdx = mul(ca, normalize( float3(px,fl) ));
                float3 rdy = mul(ca, normalize( float3(py,fl) ));

                float3 col = render( ro, rd, rdx, rdy );

                col = pow( col, float3(0.4545, 0.4545, 0.4545) );

                total += col;
                
                //return float4(rd, 1.0);

                return float4(total, 1);

            }
            ENDCG
        }
    }
}
