// § connBitSelIdxNonOvParamFold431 (control: a hex-valued localparam, golden writes no value)
module child(input a, output b);
assign b = a;
endmodule
module top(input [15:0] x, output w);
localparam H = 'he;
child c(.a(x[H]), .b(w));
endmodule
