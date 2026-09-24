// § defNetEndOnlyLoc130
// case a06: anonymous enum whose base range reads a package parameter
package pk;
  parameter int W = 3;
endpackage
module top(output logic [2:0] o);
  enum logic [pk::W-1:0] {A, B, C} x;
  assign o = x;
endmodule
