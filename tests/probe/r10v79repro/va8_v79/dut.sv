// r10v79 adversarial arm 8 — the PREDICTED REGRESSION.
// A 64-bit-typed dimension parameter makes pristine's w0 = 64, so pristine
// already matches golden on BOTH judge fields (ct 9 / sz 64).  The override is
// the NAME `UU`, written in the parent and UINT-flavoured there; inside the
// child `UU` resolves to a DIFFERENT, INT-flavoured symbol.  dimRedCt79 walks
// the initializer in the CHILD's scope and answers INT.
module child8 #(
  parameter longint Z = 4
) (input logic clk);
  localparam int UU = 3 * 2;          // INT-flavoured SHADOW
  logic [7:0] z_arr [Z+1];
endmodule

module mid8 #(parameter int unsigned N = 4) (input logic clk);
  localparam int unsigned UU = N + 1; // UINT-flavoured — the REAL override
  child8 #(.Z(UU)) u_c (.clk(clk));
endmodule

module top8;
  logic clk;
  mid8 #(.N(5)) u_a (.clk(clk));
  mid8 #(.N(7)) u_b (.clk(clk));
endmodule
