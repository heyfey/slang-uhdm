// § clsScopedBoundWholeSpan201 § clsScopedBoundPlainClass201v
class K #(int A = 2);
  localparam int V = A + 1;
  class L;
    localparam int W = 6;
  endclass
endclass
module c02 (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  assign y1 = x[K#(4)::V:0];
  assign y2 = x[K#()::L::W:1];
  assign y3 = x[K#(3)::V -: 2];
endmodule
