Shader "Terrain" 
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Heightmap ("Heightmap", 2D) = "white" {}
		_Ramp ("Ramp", 2D) = "white" {}

		_Color ("Color", Color) = (1,1,1,1)

		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_Displacement ("Displacement", Range (0, 20)) = 1

		_Darkener ("Darkener", Range (1, 5)) = 1

		[MaterialToggle] _Horizontal ("Horizontal Texture", float) = 0
		[MaterialToggle] _InvertHeightmap ("Invert Heightmap", float) = 0
		[MaterialToggle] _InvertColors ("Invert Colors", float) = 0
		[MaterialToggle] _YRamp ("Vertical Ramp", Float) = 0

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma target 3.0
		#pragma vertex vert
		#pragma surface surf Standard fullforwardshadows

		struct Input
		{
			float2 uv_MainTex;
		};

		sampler2D _MainTex;
		sampler2D _Heightmap;
		sampler2D _Ramp;

		fixed4 _Color;
		fixed _Glossiness;
		fixed _Metallic;

		fixed _InvertHeightmap;
		fixed _InvertColors;

		fixed _Darkener;
		fixed _Horizontal;
		fixed _Displacement;
		fixed _YRamp;

		void vert (inout appdata_full v)
		{
			float noiseSample = tex2Dlod (_Heightmap, float4(v.texcoord.xy, 0, 0));

			noiseSample = _InvertHeightmap == true ? 1 - noiseSample : noiseSample;

			float displacement = _Displacement - (_Displacement / 2);

			if (_YRamp)
			{
				v.vertex.xyz += v.normal * (noiseSample * displacement * v.texcoord.y);
			}
			else if (!_YRamp)
			{
				v.vertex.xyz += v.normal * (noiseSample * displacement);
			}
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			float sampleCoordinates = _Horizontal == true ? IN.uv_MainTex.y : IN.uv_MainTex.x;

			float rampSample = tex2D(_Ramp,	float2(sampleCoordinates, 1));
			
			rampSample = _InvertColors == true ? 1 - rampSample : rampSample;

			fixed textureSample = tex2D (_MainTex, IN.uv_MainTex);

			fixed4 albedo = textureSample * (rampSample / _Darkener) * _Color;

			o.Albedo = albedo.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
