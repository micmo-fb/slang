//TEST(compute):COMPARE_COMPUTE:-cpu -xslang -allow-dynamic-code
//DISABLE_TEST(compute):COMPARE_COMPUTE:-cuda -xslang -allow-dynamic-code

// Test dynamic dispatch code gen for non-static member functions.

interface IInterface
{
	int Compute(int inVal);
};

int GenericCompute<T:IInterface>(T obj, int inVal)
{
	return obj.Compute(inVal);
}

struct Impl : IInterface
{
    int base;
	int Compute(int inVal) { return base + inVal * inVal; }
};

int test(int inVal)
{
    Impl obj;
    obj.base = 1;
	return GenericCompute<Impl>(obj, inVal);
}

//TEST_INPUT:ubuffer(data=[0 1 2 3], stride=4):out,name=outputBuffer
RWStructuredBuffer<int> outputBuffer : register(u0);

[numthreads(4, 1, 1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID)
{
	uint tid = dispatchThreadID.x;
	int inVal = outputBuffer[tid];
	int outVal = test(inVal);
	outputBuffer[tid] = outVal;
}
