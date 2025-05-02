Shader "Unlit/UnlitShader1"
{
    /// <summary> 
    /// the bones of a shader 
    /// </summary>

    Properties // input data (not including mesh)
    {
        _ColorA ("Color A", Color ) = (1,1,1,1)
        _ColorB ("Color B", Color ) = (1,1,1,1)
        _ColorStart ("Color Start", Range(0,1)) = 0
        _ColorEnd ("Color End", Range(0,1)) = 1
    }
    SubShader // render pipeline related
    {
        Tags { "RenderType"="Opaque" } // for sorting

        Pass // graphics related for specific pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _ColorA;
            float4 _ColorB;

            float _ColorStart;
            float _ColorEnd;

            // automatically filled out by Unity
            struct MeshData // originally appdata, per-vertex data
            {
                float4 vertex : POSITION; // vertex position
                float3 normals : NORMAL; // float3 for a 3D vector
                    // float4 tangent : TANGENT; // float4 for sin data
                    // float4 color : COLOR; // float4 for RGBA
                float2 uv0 : TEXCOORD0; // uv0 coordinates (diffuse/normal map textures) (can be float4 for procedural)
            };

            struct v2f // vertex to fragment (used to pass data to fragment shader)) 
            {
                // in here, TEXCOORD is just an index 

                float4 vertex : SV_POSITION; // vertex position in clip space
                float3 normal : TEXCOORD0; // normal vector (3D vector)
                float2 uv : TEXCOORD1;
            };

            v2f vert (MeshData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.normal = UnityObjectToWorldNormal(v.normals); // local space to world space)
                o.uv = v.uv0; //(v.uv0 + _Offset) * _Scale; // uv coordinates (2D vector)

                return o;
            }

            float InverseLerp(float a, float b, float v) // lerp between two values
            {
                return (v - a) / (b - a);
            }

            float4 frag (v2f i) : SV_Target
            {
                // saturate is just clamp
                float t = saturate( InverseLerp(_ColorStart, _ColorEnd, i.uv.x) ); // lerp between two values (0 to 1)
                
                //t = frac(t); // wrap t between 0 and 1)

                float4 outColor = lerp(_ColorA, _ColorB, t); // lerp between two colors based on x coordinate)

                return outColor;

                //return outColor;
            }
            ENDCG
        }
    }

            /// <summary> 
            /// variable types
            /// bool 0 1 (false is 0, true is 1)
            /// int

            /// float (32 bit float)
            /// half (16 bit float) - good for most things, but usually not for PC (mobile instead)
            /// fixed (lower precision) -1 to 1

            /// lower precision typically faster

            /// float4 -> half4 -> fixed4
            /// float4x4 (4x4 matrix) -> half4x4 -> fixed4x4 (C#: Matrix4x4)

            /// use float until you need to optimize
            /// </summary>

}
