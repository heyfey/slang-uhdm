// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, output w);
localparam int XI = 5;
child c(.a(x + XI), .b(w));
endmodule
module top(input [7:0] x, output w);
sub u(.x(x), .w(w));
endmodule
