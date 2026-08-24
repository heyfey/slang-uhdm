// r10v79 adversarial arm 6 — the MIRROR of arm 5: the shadowing symbol in the
// child is INT-flavoured while the override actually written in the parent is
// UINT-flavoured.  Golden reduces the PARENT's; dimRedCt79 resolves the leaf in
// the CHILD's scope and answers INT.  Pristine answers UINT (== golden).
module child6 #(
  parameter int unsigned Z = 4
) (input logic clk);
  // Z's override is the NAME `UU`, written in the parent.  Here `UU` resolves
  // to a DIFFERENT symbol with the OPPOSITE encoding.
  localparam int UU = 3 * 2;
  logic [7:0] z_arr [Z+1];
endmodule

module mid6 #(parameter int unsigned N = 4) (input logic clk);
  localparam int unsigned UU = N + 1;   // UINT-flavoured
  child6 #(.Z(UU)) u_c (.clk(clk));
endmodule

module topv6;
  logic clk;
  mid6 #(.N(5)) u_a (.clk(clk));
  mid6 #(.N(7)) u_b (.clk(clk));
endmodule
