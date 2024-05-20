Shader "Unlit/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _HighlightColor ("Highlight Color", Color) = (1,1,1,1)
        
        _Amp ("Amplitude", Range(0, 1)) = 0.5
        _Len ("Frequency", Range(5, 100)) = 0.5
        _Frequency ("Speed", Range(0, 5)) = 0.5
        _waveNumber ("WaveNumber", Int) = 1
        _Brownian ("Brownian", Range(0.1, 0.9)) = 0.5
        _Shininess ("Shininess", Range(1, 1000)) = 0.5
        _Shadows ("Shadows", Range(0, 10)) = 0.5
        _SkyText ("Sky Texture", 2D) = "white" {}
        _Reflections ("Reflections", Range(0, 10)) = 0.5
        _Scatter ("Scatter", Range(0.1, 5)) = 0.01
    }
    SubShader
    {
        LOD 100
        
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Pass
        {
            
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            float _Brownian;
            
            float _Amp;
            float _Len;
            float _Frequency;
            int _waveNumber;

            float _Shadows;
            float _Shininess;
            float4 _HighlightColor;
            sampler2D _SkyText;
            float _Reflections;
            float _Scatter;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            float Wave(float2 uv, float waveAmp, float waveLen, float frequency, float2 waveDir)
            {
                float dir = uv.x * waveDir.x + uv.y * waveDir.y;
                float phase = dir * waveLen + _Time.y * frequency;
                float result = waveAmp * exp(sin(phase) - 1);
                return result;
            }
            
            float WaveDerivative(float2 uv, float waveAmp, float waveLen, float frequency, float2 waveDir, float2 der)
            {
                float dir = uv.x * waveDir.x + uv.y * waveDir.y;
                float phase = dir * waveLen + _Time.y * frequency;

                float dPhase_dx = waveLen * waveDir.x;
                float dPhase_dy = waveLen * waveDir.y;

                float dPhase = der.x * dPhase_dx + der.y * dPhase_dy;

                float result = waveAmp * exp(sin(phase) - 1) * cos(phase) * dPhase;

                return result;
            }

            float WaveWarped(float2 uv, float waveAmp, float waveLen, float frequency, float2 waveDir, float prevDerivative)
            {
                float dir = uv.x * waveDir.x + uv.y * waveDir.y;
                float phase = (dir + prevDerivative) * waveLen + _Time.y * frequency;
                float result = waveAmp * exp(sin(phase) - 1);
                return result;
            }

            v2f vert (appdata v)
            {
                v2f o;

                float toAdd = 0;
                for (int i = 0; i < _waveNumber; i++)
                {
                    toAdd += Wave(v.uv, _Amp * pow(1 - _Brownian, i), _Len * pow(1 + _Brownian, i), _Frequency, float2(sin(0.0 + _Scatter*i), cos(0.0 + _Scatter*i)));
                }
                
                v.vertex.y += toAdd;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

             

            float4 frag (v2f i) : SV_Target
            {
                float4 t = _Color;

                float3 foam = 0;
                float3 N = float3(0, 0, 1);
                for (int j = 0; j < _waveNumber; j++)
                {
                    float3 T = float3(1, 0, WaveDerivative(i.uv, _Amp * pow(1 - _Brownian, j), _Len * pow(1 + _Brownian, j), _Frequency, float2(sin(0.0 + _Scatter*j), cos(0.0 + _Scatter*j)), float2(1, 0)));
                    float3 B = float3(0, 1, WaveDerivative(i.uv, _Amp * pow(1 - _Brownian, j), _Len * pow(1 + _Brownian, j), _Frequency, float2(sin(0.0 + _Scatter*j), cos(0.0 + _Scatter*j)), float2(0, 1)));
                    N += cross(T, B);

                }
                N = normalize(N);

                float3 L = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 H = normalize(L + V);

                float diffuse = pow(max(dot(N, _WorldSpaceLightPos0), 0.0), _Shadows);
                float specular = pow(max(dot(N, H), 0.0), 1000-_Shininess);
                float reflection = 2 * N * DotClamped(N, V) - V;

                t.rgb *= diffuse;
                t.rgb += specular * _HighlightColor.rgb;
                t.rgb *= pow(max(tex2D(_SkyText, reflection).rgb, 0) + 1, _Reflections);
                t.a = 0.95;
                
                
                return t;
            }
            ENDCG
        }
    }
}
