// § enumSubstDecDecompile411
package p;
  typedef enum logic [2:0] { P = 3'd0, W = 3 } d_t;
endpackage
module top (input logic [2:0] x, output logic [2:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    wire t = (x == p::P);
  end
  assign o = p::W + p::P;
endmodule
