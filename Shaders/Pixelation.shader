Shader "Unlit/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Density ("Density", Range(1, 500)) = 60
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
            //BLEND SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Density;
            

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
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float aspectRatio = _ScreenParams.y / _ScreenParams.x;
                float2 uv = floor(float2(i.uv.x * floor(_Density), i.uv.y*_Density * aspectRatio));
                uv.x /= _Density;
                uv.y = uv.y / aspectRatio / _Density;
                float4 colorTex = tex2D(_MainTex, uv);
                
                return colorTex;
            }
            ENDCG
        }
    }
}
