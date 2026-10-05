// § impCondFlipTakenLeaf242
// Non-integral ternaries: real and string results, and an enum result, imported by an importer with a parameter port list.
package fp;
  typedef enum logic [1:0] {A, B, C} e_t;
  parameter int WM = 2;
  parameter real R = WM == 1 ? 1.5 : 2.5;
  parameter string S = WM == 1 ? "a" : "bb";
  parameter e_t E = WM == 1 ? A : C;
  parameter int W = WM == 1 ? 1 : 3;
endpackage
module top import fp::*; #(parameter int P = 1) (output logic [W-1:0] o, output e_t e);
  assign o = '0;
  assign e = E;
endmodule
