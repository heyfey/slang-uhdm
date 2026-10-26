// § connBitSelIdxNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
interface ifc(input logic [7:0] x);
  logic o;
  localparam P = 3;
endinterface
module sub(input [7:0] x, output w);
localparam P = 5;
ifc i(.x(x[P:0] ));
child c(.a(x[P]), .b(w));
endmodule
module top(input [7:0] x, output w); sub u(.x(x), .w(w)); endmodule
