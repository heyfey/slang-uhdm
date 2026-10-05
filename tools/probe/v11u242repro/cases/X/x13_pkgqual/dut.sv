// § impCondFlipTakenLeaf242
// A package-qualified read with no import, an empty parameter port list with a wildcard import, an untyped and a logic-typed ternary.
package fp;
  parameter int WM = 2;
  parameter int LB = 3;
  parameter W = WM == 1 ? 1 : LB;
  parameter logic [3:0] V = WM == 2 ? 4'd2 : LB;
endpackage
module m2 #(parameter int P = 1) (input logic [7:0] a, output logic [fp::V-1:0] o);
  assign o = a[fp::V-1:0];
endmodule
module m3 import fp::*; #() (input logic [7:0] a, output logic [V-1:0] o, output logic [W-1:0] w);
  assign o = a[V-1:0];
  assign w = a[W-1:0];
endmodule
module top (input logic [7:0] a, output logic [1:0] o2, output logic [1:0] o3, output logic [2:0] w);
  m2 u2 (.a(a), .o(o2));
  m3 u3 (.a(a), .o(o3), .w(w));
endmodule
