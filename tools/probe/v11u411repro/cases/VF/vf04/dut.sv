// § enumSubstDecDecompile411
package p;
  typedef enum logic [2:0] { P = 3'd0, W, E } d_t;
endpackage
module top #(parameter logic [2:0] D = p::W) (input logic [2:0] x, output logic o);
  always_comb case (x)
    p::P: o = 1'b1;
    p::E: o = 1'b0;
    default: o = (x == D);
  endcase
endmodule
