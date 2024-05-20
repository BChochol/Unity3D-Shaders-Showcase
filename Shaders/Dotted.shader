Shader "Unlit/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Density ("Density", Range(1, 500)) = 1
        _Size ("Size", Range(0, 20)) = 0.5
        _Intensity ("Intensity", Range(0, 10)) = 1
    }
    SubShader
    {
        LOD 100
        
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }

        Pass
        {
            BLEND SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Density;
            float _Size;
            float _Intensity;
            

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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex =  UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                float2 coords = float2(i.uv.x * floor(_Density), i.uv.y*floor(_Density) * _ScreenParams.y / _ScreenParams.x);
                float4 t2 = max(1-(distance(float2(0.5, 0.5), frac(float4(coords,0, 1))) - _Size/10 + 1), 0)*_Intensity;
                // float4 t = float4(i.uv,0, 1);
                // t = frac(t);
                // float4 dist = distance(float2(0.5, 0.5), t);
                // t = dist - _Size +1;
                // float4 stepped = 1-t;
                // stepped = max(stepped, 0) * _Intensity;
                //return float4(1, 1, 1, stepped.a);
                //return _MainTex + float4(1, 1, 1, t2.a);

                texColor += t2;
                return texColor;
            }
            ENDCG
        }
    }
}
