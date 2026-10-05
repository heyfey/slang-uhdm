// § impCondFlipTakenLeaf242
// The taken leaf and the whole ternary written through macros; importer with a parameter port list.
`define SEL(c, a, b) ((c) ? (a) : (b))
`define LB_OF(x) x
package fp;
  parameter int WM = 2;
  parameter int LB = $clog2(WM);
  parameter int W1 = WM == 1 ? 1 : `LB_OF(LB);
  parameter int W2 = `SEL(WM == 1, 1, LB);
endpackage
module top import fp::*; #(parameter bit S = 1) (input logic [7:0] a, output logic [W1-1:0] o, output logic [W2-1:0] q);
  assign o = a[0 +: W1];
  assign q = a[W2-1:0];
endmodule
