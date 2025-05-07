Shader "Unlit/VertexOffset"
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
        _WaveAmp ("Wave Amplitude", Range(0,0.02)) = 0.01
    }
    SubShader // render pipeline related
    {
        Tags { "RenderType"="Opaque" 
               "Queue" = "Geometry" } 

        Pass // graphics related for specific pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283185307179586476925286766559 // 2 * PI

            float4 _ColorA;
            float4 _ColorB;

            float _ColorStart;
            float _ColorEnd;

            float _WaveAmp;

            // automatically filled out by Unity
            struct MeshData // originally appdata, per-vertex data (input into vertex shader)
            {
                float4 vertex : POSITION; // vertex position
                float3 normals : NORMAL; // float3 for a 3D vector
                    // float4 tangent : TANGENT; // float4 for sin data
                    // float4 color : COLOR; // float4 for RGBA
                float2 uv0 : TEXCOORD0; // uv0 coordinates (diffuse/normal map textures) (can be float4 for procedural)
                float2 uv1 : TEXCOORD1; // uv1 coordinates lightmap coords
            };

            struct v2f // vertex to fragment (used to pass data to fragment shader)) 
            {
                // in here, TEXCOORD is just an index 

                float4 vertex : SV_POSITION; // set vertex position in clip space (always required)
                float3 normal : TEXCOORD0; // normal vector (3D vector)
                float2 uv : TEXCOORD1;
            };

            float GetWave(float2 uv){
                float2 uvsCentered = uv * 2 - 1; // remaps the center of the mesh as 0, values are now between -1 and 1
                float radialDistance = length(uvsCentered); // distance from the center of the mesh
                float wave = cos((radialDistance - _Time.y * 0.1) * TAU * 5); // this is done in uv space 
                wave *= 1 - radialDistance; // fade out the edges

                return wave;
                }

            v2f vert (MeshData v)
            {
                v2f o;
                
                //float wave = cos((v.uv0.y - _Time.y * 0.1) * TAU * 5); 
                //float wave2 = cos((v.uv0.x - _Time.y * 0.1) * TAU * 5); 

                //v.vertex.z = wave /* * wave2 */ * _WaveAmp;

                v.vertex.z = GetWave(v.uv0) * _WaveAmp; // offset the vertex position in the z direction)

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
                //float col = saturate( InverseLerp(_ColorStart, _ColorEnd, i.uv.y) ); // lerp between two values (0 to 1) // saturate is just clamp
                //float t = abs(frac(i.uv.x * 5) * 2 - 1); // Triangle Wave

                //return float4(i.uv, 0, 1);

                //return i.uv.y; // return the y coordinate of the uv (0 to 1)

                return GetWave(i.uv);
            }
            ENDCG
        }
    }
}
