Shader "Custom/JumpRotate"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1,1,1,1)
        _JumpSpeed ("Jump Speed", Range(0, 1)) = 1.0
        _JumpHeight ("Jump Height", Range(0, 1)) = 0.5
        _RotationSpeed ("Rotate Speed", Range(0, 1)) = 1.0

        _AmbientColor ("Ambient Color", Color) = (1, 1, 1, 1)
        _AmbientIntensity ("Ambient Intensity", Range(0, 1)) = 0.1
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _LightPosition ("Light Position", Vector) = (0, 1, 0, 1) 
        _LightIntensity ("Light Intensity", Range(0, 8)) = 1.0
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 0.5
        _Shininess ("Shininess", Range(0.01, 256)) = 32
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float _JumpSpeed;
            float _RotationSpeed;
            float _JumpHeight;

            // Lighting properties
            float4 _AmbientColor;
            float _AmbientIntensity;
            float4 _LightColor;
            float3 _LightPosition;
            float _LightIntensity;
            float4 _SpecularColor;
            float _SpecularIntensity;
            float _Shininess;

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
                float2 uv : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float jump = sin(_Time.y * _JumpSpeed * 10.0) * 0.5 + 0.5;
                v.vertex.y += jump * _JumpHeight;

                float angle = _Time.y * _RotationSpeed * 10.0;
                float s = sin(angle);
                float c = cos(angle);
                float2x2 rotationMatrix = float2x2(c, s, -s, c); 
                float2 rotated = mul(rotationMatrix, v.vertex.xz);
                v.vertex = float4(rotated.x, v.vertex.y, rotated.y, v.vertex.w);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 lightPos = normalize(_WorldSpaceLightPos0.xyz);
                fixed4 tex = tex2D(_MainTex, i.uv) * _Color;

                float3 normal = normalize(i.normal);

                float angle = _Time.y * _RotationSpeed * 10.0;

                float s = sin(angle);
                float c = cos(angle);
                float2x2 rotationMatrix = float2x2(c, s, -s, c);
                float2 rotated = mul(rotationMatrix, lightPos.xz);
                float3 lightDirObj = normalize(float3(-rotated.x, lightPos.y, rotated.y));

                fixed3 ambient = _AmbientColor.rgb * _AmbientIntensity;
                fixed3 diffuse = _LightColor.rgb * _LightIntensity * max(0.0, dot(normal, lightDirObj));
                fixed3 specular = _SpecularColor.rgb * _SpecularIntensity * pow(max(0.0, dot(reflect(-lightDirObj, normal), normalize(_WorldSpaceCameraPos - i.worldPos))), _Shininess);

                fixed4 finalColor = fixed4(tex.rgb * (ambient + diffuse) + specular, tex.a);

                return finalColor;
            }

            ENDCG
        }
    }
}
