// § impCondFlipTakenLeaf242
// One taken leaf alone: WM == 1 ? 1 : (LB), importer with a parameter port list, read in a part-select bound.
package fp;
  parameter int WM = 2;
  parameter int LB = 3;
  parameter int L = WM == 1 ? 1 : (LB);
endpackage
module top import fp::*; #(parameter int P = 1) (input logic [15:0] a, output logic [3:0] o);
  assign o = a[L +: 4];
endmodule
