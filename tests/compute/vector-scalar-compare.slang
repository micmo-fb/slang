//TEST(compute):COMPARE_COMPUTE:-dx12 -compute 
//TEST(compute):COMPARE_COMPUTE:-vk -compute 
//TEST_INPUT:ubuffer(data=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0], stride=4):out

// Test doing vector comparisons 
RWStructuredBuffer<int> outputBuffer;

[numthreads(4, 4, 1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID)
{
    uint2 threadInGroup = dispatchThreadID.xy;
    
    int r = 0;
    if(all((threadInGroup & 1) == 0))
    {
        r = 0;
    }
    else
    {   
        r = 1;
    }
   
    int index = threadInGroup.x + threadInGroup.y * 4; 
    outputBuffer[index] = r;
}