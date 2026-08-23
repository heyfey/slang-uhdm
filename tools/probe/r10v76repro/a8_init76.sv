// r10v76 arm a8 -- IS IT `initial`, OR IS IT `forever`/`#delay`?  a5 measured
// golden REFUSING in a gen-scope `initial`'s forever body and in a
// delay-controlled statement, and FOLDING in a gen-scope `always_comb` and
// `always @(posedge clk)`.  This arm puts a PLAIN, undelayed statement in a
// gen-scope `initial` beside them so the discriminator can be named.
package v76p8;
  parameter int NB = 4;
endpackage
module v76init #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  import v76p8::*;
  logic [31:0] i1, i2, i3, i4;
  if (P > 0) begin : gi_p
    initial begin
      i1 = '0;
      i1 = i1 + NB;              // PLAIN statement in a gen-scope `initial`
      if (NB > 1) i1 = i1 + 1;   // an `if` condition beside it
    end
  end
  if (P > 0) begin : gi_q
    initial i2 = NB;             // a one-statement gen-scope `initial`
  end
  if (P > 0) begin : gi_r
    always begin                 // a gen-scope `always` with no event control
      i3 = i3 + NB;
      #1;
    end
  end
  if (P > 0) begin : gi_s
    final i4 = i4 + NB;          // a gen-scope `final`
  end
  assign o = i1 ^ i2 ^ i3 ^ i4;
endmodule
module v76inittop (input logic clk, output logic [31:0] o1);
  v76init #(2) u_i (.clk(clk), .o(o1));
endmodule
