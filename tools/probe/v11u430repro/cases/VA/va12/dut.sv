// § clsArrPropConcatInitElemSize430
class C; localparam int K = 4; int a[2] = {K, 5}; endclass
module top; C c; initial c = new; endmodule
