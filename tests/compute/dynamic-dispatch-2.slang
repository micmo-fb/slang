//TEST(compute):COMPARE_COMPUTE:-cpu -xslang -allow-dynamic-code
//DISABLE_TEST(compute):COMPARE_COMPUTE:-cuda -xslang -allow-dynamic-code

// Test dynamic dispatch code gen for static member functions
// of associated type.

interface IAssoc
{
    int get();
    static int getBase();
}
interface IInterface
{
    associatedtype Assoc : IAssoc;
	int Compute(int inVal);
};

int GenericCompute<T:IInterface>(T obj, int inVal)
{
	return obj.Compute(inVal) + T.Assoc.getBase();
}

struct Impl : IInterface
{
    struct Assoc : IAssoc
    {
        int val;
        int get() { return val; }
        static int getBase() { return -1; }
    };
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
