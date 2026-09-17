// v11u64 verifier grid 4 — the OTHER carrier that reaches the stamp: a
// PACKAGE-scope struct variable with a structured-pattern declaration
// initializer (src/ModuleEmit.cpp `structuredPkgPat`), the one arm where the
// law's `default:` half runs with no instance-aware walk behind it.
package pz;
  localparam int PW = 5;
  parameter  int QW = 6;
  typedef struct packed { logic [7:0] a; logic [PW-1:0] b; logic [QW-1:0] c; } t;
  t gv  = '{a: 8'd1, default: '0};
  t gv2 = '{a: 8'd1, b: '0, c: '1};
endpackage

module vz1 (input logic [63:0] pa, output logic o);
  pz::t s;
  assign s = '{a: pa, b: '0, c: '0};
  assign o = ^{s, pz::gv, pz::gv2};
endmodule

module vtb4;
  logic [63:0] pa;
  logic o;
  vz1 z1 (.pa(pa), .o(o));
endmodule
