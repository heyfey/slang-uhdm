// § impCondFlipTakenLeaf242
// An enum-typed ternary (enum constant leaves) imported by an importer with a parameter port list.
package fp;
  typedef enum logic [1:0] {A, B, C} e_t;
  parameter int WM = 2;
  parameter e_t E = WM == 1 ? A : C;
endpackage
module top import fp::*; #(parameter int P = 1) (output e_t e);
  assign e = E;
endmodule
