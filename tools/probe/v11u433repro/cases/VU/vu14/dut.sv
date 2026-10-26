// § connOpUnitParamFold433
localparam S = 2;
module c(input [7:0] a); endmodule
function automatic int f(int v); return v; endfunction
module top; logic [7:0] x; c u(.a(f(x + S))); endmodule
