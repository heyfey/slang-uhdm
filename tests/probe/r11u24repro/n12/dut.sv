// n12 — A WHOLE-MEMBER WRITE FROM ANOTHER PARAMETER, FLAT ONLY.  `c.u = UU`
// with `UU` a package localparam whose own elaborated Rhs is an assignment
// PATTERN operation: golden's leftover IS that operation object.  Everything
// here is first-level, so whatever this arm reads is the FLAT family's answer
// and must be IDENTICAL pristine and patched — it is n3's remaining head.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::in_t S = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
