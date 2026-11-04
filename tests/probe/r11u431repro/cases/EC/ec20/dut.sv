// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
function automatic int f(int a); return a; endfunction
module top(input [15:0] x, output w);
localparam K = 3;
child c(.a(x[f(K)]), .b(w));
endmodule
