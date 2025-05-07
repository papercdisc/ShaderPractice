Shader "Unlit/Textured"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tex2 ("Texture 2", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
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

            #define TAU 6.283185307179586476925286766559 // 2 * PI

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _Tex2;
            sampler2D _Pattern;

            float GetWave(float2 coord)
            {
                float wave = cos((coord - _Time.y * 0.1) * TAU * 5); // this is done in uv space 
                wave *= coord; // fade out the edges

                return wave;
            }

            v2f vert (MeshData v)
            {
                v2f o;
                o.worldPos = mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1)); // obj to world
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; // pass through the uv coordinates
                //o.uv.x += _Time.y * 0.1;
                return o;
            }


            float4 frag (v2f i) : SV_Target
            {
                float2 topDownProjection = i.worldPos.xz; // project the world position to 2D

                //return float4(topDownProjection, 0, 1);

                // sample the texture
                float4 col = tex2D(_MainTex, topDownProjection); // texture is mapped to world space (tiling and size remains constant along x and z)
                float4 tex2 = tex2D(_Tex2, topDownProjection); // sample the second texture
                float pattern = tex2D(_Pattern, i.uv).x; // sample the pattern texture

                float4 finalColor = lerp(tex2, col, pattern); // lerp between the pattern and the texture color)

                //return GetWave(pattern);

                return finalColor;
            }
            ENDCG
        }
    }
}
