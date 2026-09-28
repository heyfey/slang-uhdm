// § pkgFoldAtLeadingLeaf191 — v11u195 fresh: taken arms that are a unary minus, a system call, a nested product in parentheses, a cast
package p;
  localparam int L = 4;
  localparam bit C = 1;
  parameter int P1 = C ? -L : 2;
  parameter int P2 = C ? $clog2(L) : 1;
  parameter int P3 = C ? (L * 2) + 1 : 1;
  parameter int P4 = !C ? 1 : int'(L) + 3;
endpackage
module top (input logic [p::P1+p::P2+p::P3+p::P4+10:0] i, output logic o);
  assign o = i[0];
endmodule
