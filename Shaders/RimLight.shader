Shader "Unlit/Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Intensity ("Intensity", Range(0, 1)) = 1
        _Power ("Power", Range(0, 1)) = 1
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
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float _Intensity;
            float _Power;
            

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
                float3 cameraVec : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex =  UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.cameraVec = WorldSpaceViewDir(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);
                i.cameraVec = normalize(i.cameraVec);
                
                float3 dotP = dot(i.normal, i.cameraVec);
                dotP =  pow((1-dotP), _Power)*_Intensity;
                float4 dotP4 = float4(dotP.rrr, 1);
                return lerp(tex2D(_MainTex, i.uv), _Color, dotP4);
            }
            ENDCG
        }
    }
}
