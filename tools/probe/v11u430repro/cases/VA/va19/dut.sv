// § clsArrPropConcatInitElemSize430
class C; logic signed [7:0] b[2] = {-1, 2}; integer i[2] = {1, 2}; endclass
module top; C c; initial c = new; endmodule
