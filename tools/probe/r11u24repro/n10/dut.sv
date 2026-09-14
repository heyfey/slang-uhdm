// n10 — THE SHARED STRUCT TYPESPEC, FLAT WRITES ONLY.  Two package localparams
// built by two DIFFERENT functions that return the SAME typedef: the leftovers
// land on ONE typespec, and golden's copy carries the LAST-EVALUATED
// parameter's.  Everything here is first-level, so whatever this arm reads is
// the FLAT family's own answer and must be IDENTICAL pristine and patched.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  function automatic c_t mkA();
    c_t c; c.a = 3; c.b = 32; return c;
  endfunction
  function automatic c_t mkB();
    c_t c; c.a = 5; c.b = 9; return c;
  endfunction
  localparam c_t CA = mkA();
  localparam c_t CB = mkB();
endpackage

module kid #(
    parameter pk::c_t P1 = pk::CA,
    parameter pk::c_t P2 = pk::CB
) (output logic o);
  localparam int X1 = P1.a;
  localparam int X2 = P2.a;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
