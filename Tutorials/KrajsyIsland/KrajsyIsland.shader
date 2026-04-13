Shader "Unlit/krajsyIslandV2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float noiseMethod(float2 uv)
            {
                float fpA = 127.1;
                float fpB = 311.7;
                float fpC = 269.5;
                float fpD = 183.3;
                float fpE = 43758.5453123;

                float2 i = floor(uv * 2.);
                float2 f = frac(uv * 2.);
                float2 t = f * f * f * ( f * ( f * 6.0 - 15.0 ) + 10.0 );
                float2 a = i + float2( 0.0, 0.0 );
                float2 b = i + float2( 1.0, 0.0 );
                float2 c = i + float2( 0.0, 1.0 );
                float2 d = i + float2( 1.0, 1.0 );
                a = -1.0 + 2.0 * frac( sin( float2( dot( a, float2( fpA, fpB ) ),dot( a, float2( fpC, fpD ) ) ) ) * fpE );
                b = -1.0 + 2.0 * frac( sin( float2( dot( b, float2( fpA, fpB ) ),dot( b, float2( fpC, fpD ) ) ) ) * fpE );
                c = -1.0 + 2.0 * frac( sin( float2( dot( c, float2( fpA, fpB ) ),dot( c, float2( fpC, fpD ) ) ) ) * fpE );
                d = -1.0 + 2.0 * frac( sin( float2( dot( d, float2( fpA, fpB ) ),dot( d, float2( fpC, fpD ) ) ) ) * fpE );
                float A = dot( a, f - float2( 0.0, 0.0 ) );
                float B = dot( b, f - float2( 1.0, 0.0 ) );
                float C = dot( c, f - float2( 0.0, 1.0 ) );
                float D = dot( d, f - float2( 1.0, 1.0 ) );
                float noise = ( lerp( lerp( A, B, t.x ), lerp( C, D, t.x ), t.y ) );

                return clamp(1.5 * noise, -1.0, 1.0 )*.5+.5;
            }

            float getFalloff(float2 uv)
            {
                float land = smoothstep(.2, .5, length(uv - .5));
                return 1.-clamp(land, 0., 1.);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 noiseUv = uv;
                float4 col = 1;
                
                float noise = getFalloff(noiseUv) * noiseMethod((uv * 2.0 +100.));
                fixed3 color = step(.5, noise);

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}