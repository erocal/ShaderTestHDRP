float DistanceFadeClip(float4 screenPosition, sampler2D _DitherPattern, float4 _DitherPattern_TexelSize, float _MinDistance, float _MaxDistance)
{
	//value from the dither pattern
	float2 screenPos = screenPosition.xy / screenPosition.w;
	float2 ditherCoordinate = screenPos * _ScreenParams.xy * _DitherPattern_TexelSize.xy;
	float ditherValue = tex2D(_DitherPattern, ditherCoordinate).r;

	//get relative distance from the camera
	float relDistance = screenPosition.w;
	relDistance = relDistance - _MinDistance;
	relDistance = relDistance / (_MaxDistance - _MinDistance);

	return relDistance - ditherValue;
}