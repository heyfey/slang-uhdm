// § clsArrPropConcatInitElemSize430
class C #(int N = 2); int a[N] = {1, 2}; endclass
module top; C #() c; initial c = new; endmodule
