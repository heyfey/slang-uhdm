// § clsScopedBoundWholeSpan201 § clsScopedBoundPlainClass201v
class K;
  parameter int P = 5;
  localparam int V = 3;
  typedef enum int { E0 = 1, E1 = 4 } e_t;
endclass
module c01 (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4);
  assign y1 = x[K::P:K::V];
  assign y2 = x[K::E1:K::E0];
  assign y3 = x[K::V +: 2];
  assign y4 = x[K::P -: K::V];
endmodule
