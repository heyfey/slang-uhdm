// § impCondFlipTakenLeaf242
// An explicit (by-name) import of the ternary parameter by an importer with a parameter port list.
package fp;
  parameter int WM = 2;
  parameter int LB = 3;
  parameter int W = WM == 1 ? 1 : LB;
endpackage
module top import fp::W; #(parameter int P = 1) (input logic [7:0] a, output logic [W-1:0] o);
  assign o = a[W-1:0];
endmodule
