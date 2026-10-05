// § impCondFlipTakenLeaf242
// A real-typed ternary imported by an importer with a parameter port list.
package fp;
  parameter int WM = 2;
  parameter real R = WM == 1 ? 1.5 : 2.5;
  parameter int W = WM == 1 ? 1 : 3;
endpackage
module top import fp::*; #(parameter int P = 1) (output logic [W-1:0] o);
  assign o = '0;
endmodule
