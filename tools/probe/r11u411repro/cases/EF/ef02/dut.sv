// § enumSubstDecDecompile411
package p;
  typedef enum logic [2:0] { P = 3'd0, W, E } d_t;
endpackage
module top (output logic o);
  initial assert (p::P == 0 && p::W == 1) else $error("bad");
  assign o = 1'b0;
endmodule
