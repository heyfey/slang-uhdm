// t7 — a NON-local module parameter defaulted to a member read, and the same
// parameter overridden at an instance.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  function automatic c_t mk();
    c_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module leaf #(
    parameter pk::c_t G = pk::C,
    parameter int     N = G.a,     // NON-local parameter, member-read default
    parameter int     M = G.b      // ...overridden at u1
) (output logic o);
  assign o = ^{N[0], M[0]};
endmodule

module dut(output logic o1, output logic o2);
  leaf u0 (.o(o1));
  leaf #(.M(7)) u1 (.o(o2));
endmodule
