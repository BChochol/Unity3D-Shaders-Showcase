Shader "Unlit/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Density ("Density", Range(1, 500)) = 1
        _Intensity ("Intensity", Range(0, 1)) = 0.5
        
        _RedColor ("Red Color",Range(0,1)) = 1
        _GreenColor ("Green Color",Range(0,1)) = 1
        _BlueColor ("Blue Color",Range(0,1)) = 1
        
        _Difference ("Difference", Range(0, 1)) = 0.5
        _Brightness ("Brightness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        LOD 100
        
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
            "LightMode"="ForwardBase"
        }

        Pass
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            sampler2D _MainTex;
            float _Density;
            float _Intensity;
            float _RedColor;
            float _GreenColor;
            float _BlueColor;
            float _Difference;
            float _Brightness;
            

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
                float2 worldUv : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex =  UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv =  v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 normal = i.normal;
                float3 lightPos = normalize(_WorldSpaceLightPos0.xyz);

                float3 diffuseLight = saturate(dot(normal, lightPos));
                
                float2 coords = float2(i.uv.x * _Density, i.uv.y*_Density * _ScreenParams.y / _ScreenParams.x);
                float4 dotsPattern = max(1-distance(float2(0.5, 0.5), frac(float4(coords,0, 1))), 0);

                float4 lighted = float4(diffuseLight, 1);

                float4 ret = (1-step(lighted * dotsPattern, _Intensity))*_Difference+_Brightness;

                return float4(ret.r*_RedColor, ret.g*_GreenColor, ret.b*_BlueColor, 1);
            }
            ENDCG
        }
    }
}
