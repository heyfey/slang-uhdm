// § connBitSelIdxNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
typedef enum logic [2:0] {E0, E1, E2, E3} e_t;
module sub(input [7:0] x, output w);
localparam e_t P = E2;
child c(.a(x[P]), .b(w));
endmodule
module top(input [7:0] x, output w); sub u(.x(x), .w(w)); endmodule
