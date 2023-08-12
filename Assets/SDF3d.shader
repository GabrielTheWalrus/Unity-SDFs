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

            // funções do shader
            float3x3 setCamera( float3 ro, float3 ta, float cr )
            {
                float3 cw = normalize(ta-ro);
                float3 cp = float3(sin(cr), cos(cr),0.0);
                float3 cu = normalize( cross(cw,cp) );
                float3 cv =          ( cross(cu,cw) );

                return float3x3( cu, cv, cw );
            }

            float3 render( float3 ro, float3 rd, float3 rdx, float3 rdy )
            { 
                // background
                float3 col = float3(0.7, 0.7, 0.9) - max(rd.y,0.0)*0.3;
                
                // raycast scene
                // vec2 res = raycast(ro,rd);
                // float t = res.x;
                // float m = res.y;
                // if( m>-0.5 )
                // {
                //     vec3 pos = ro + t*rd;
                //     vec3 nor = (m<1.5) ? vec3(0.0,1.0,0.0) : calcNormal( pos );
                //     vec3 ref = reflect( rd, nor );
                    
                //     // material        
                //     col = 0.2 + 0.2*sin( m*2.0 + vec3(0.0,1.0,2.0) );
                //     float ks = 1.0;
                    
                //     if( m<1.5 )
                //     {
                //         // project pixel footprint into the plane
                //         vec3 dpdx = ro.y*(rd/rd.y-rdx/rdx.y);
                //         vec3 dpdy = ro.y*(rd/rd.y-rdy/rdy.y);

                //         float f = checkersGradBox( 3.0*pos.xz, 3.0*dpdx.xz, 3.0*dpdy.xz );
                //         col = 0.15 + f*vec3(0.05);
                //         ks = 0.4;
                //     }

                //     // lighting
                //     float occ = calcAO( pos, nor );
                    
                //     vec3 lin = vec3(0.0);

                //     // sun
                //     {
                //         vec3  lig = normalize( vec3(-0.5, 0.4, -0.6) );
                //         vec3  hal = normalize( lig-rd );
                //         float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
                //     //if( dif>0.0001 )
                //             //dif *= calcSoftshadow( pos, lig, 0.02, 2.5 );
                //         float spe = pow( clamp( dot( nor, hal ), 0.0, 1.0 ),16.0);
                //             spe *= dif;
                //             spe *= 0.04+0.96*pow(clamp(1.0-dot(hal,lig),0.0,1.0),5.0);
                //             //spe *= 0.04+0.96*pow(clamp(1.0-sqrt(0.5*(1.0-dot(rd,lig))),0.0,1.0),5.0);
                //         lin += col*2.20*dif*vec3(1.30,1.00,0.70);
                //         lin +=     5.00*spe*vec3(1.30,1.00,0.70)*ks;
                //     }
                //     // sky
                //     {
                //         float dif = sqrt(clamp( 0.5+0.5*nor.y, 0.0, 1.0 ));
                //             dif *= occ;
                //         float spe = smoothstep( -0.2, 0.2, ref.y );
                //             spe *= dif;
                //             spe *= 0.04+0.96*pow(clamp(1.0+dot(nor,rd),0.0,1.0), 5.0 );
                //     //if( spe>0.001 )
                //             //spe *= calcSoftshadow( pos, ref, 0.02, 2.5 );
                //         lin += col*0.60*dif*vec3(0.40,0.60,1.15);
                //         lin +=     2.00*spe*vec3(0.40,0.60,1.30)*ks;
                //     }
                //     // back
                //     {
                //         float dif = clamp( dot( nor, normalize(vec3(0.5,0.0,0.6))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
                //             dif *= occ;
                //         lin += col*0.55*dif*vec3(0.25,0.25,0.25);
                //     }
                //     // sss
                //     {
                //         float dif = pow(clamp(1.0+dot(nor,rd),0.0,1.0),2.0);
                //             dif *= occ;
                //         lin += col*0.25*dif*vec3(1.00,1.00,1.00);
                //     }
                    
                //     col = lin;

                //     col = mix( col, vec3(0.7,0.7,0.9), 1.0-exp( -0.0001*t*t*t ) );
                // }

                return float3( clamp(col,0.0,1.0) );
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                // camera
                float3 ta = float3( 0.25, -0.75, -0.75 );

                float a = 4.5 * cos(0.1 * _Time + 7.0);
                float b = 4.5 * sin(0.1*_Time + 7.0);

                float3 ro = ta + float3( a, 2.2, b);

                // camera-to-world transformation
                float3x3 ca = setCamera( ro, ta, 0.0 );

                float3 total = float3(0.0, 0.0, 0.0);

                float2 viewport_quad = float2(1.0, 1.0);
                
                        
                float2 p = (2.0 * i.uv-viewport_quad.xy)/viewport_quad.y;

                    // focal length
                float fl = 2.5;
                
                // ray direction
                float3 rd = mul(ca, normalize( float3(p,fl) ));

                // ray differentials
                float2 px = (2.0 * (i.uv + float2(1.0,0.0)) - viewport_quad.xy)/viewport_quad.y;
                float2 py = (2.0 * (i.uv + float2(0.0,1.0)) - viewport_quad.xy)/viewport_quad.y;
                float3 rdx = mul(ca, normalize( float3(px,fl) ));
                float3 rdy = mul(ca, normalize( float3(py,fl) ));

                //float2 teste = (2.0 * (i.uv + float2(1.0,0.0)) - viewport_quad.xy)/viewport_quad.y;;

                float3 col = render( ro, rd, rdx, rdy );

                col = pow( col, float3(0.4545, 0.4545, 0.4545) );

                total += col;

                    

                return float4(total, 1);

            }
            ENDCG
        }
    }
}
