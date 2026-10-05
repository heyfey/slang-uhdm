// § impCondFlipTakenLeaf242
// Explicit import of the ternary parameter, a package-qualified read without an import, an empty parameter port list, and an untyped and a logic-typed ternary.
package fp;
  parameter int WM = 2;
  parameter int LB = 3;
  parameter W = WM == 1 ? 1 : LB;
  parameter logic [3:0] V = WM == 2 ? 4'd2 : LB;
endpackage
module m1 import fp::W; #(parameter int P = 1) (input logic [7:0] a, output logic [W-1:0] o);
  assign o = a[W-1:0];
endmodule
module m2 #(parameter int P = 1) (input logic [7:0] a, output logic [fp::V-1:0] o);
  assign o = a[fp::V-1:0];
endmodule
module m3 import fp::*; #() (input logic [7:0] a, output logic [V-1:0] o);
  assign o = a[V-1:0];
endmodule
module top (input logic [7:0] a, output logic [2:0] o1, output logic [1:0] o2, output logic [1:0] o3);
  m1 u1 (.a(a), .o(o1));
  m2 u2 (.a(a), .o(o2));
  m3 u3 (.a(a), .o(o3));
endmodule
