// a16 — THE NEGATIVE CONTROL for the split: the member is EXACTLY the
// pattern's natural width (`mw` 64, `n` 2, `ew` 32), so `mw / n` and the
// whole-slice road give the SAME bits.  This arm must be CMP_EQUAL on BOTH
// binaries and byte-identical between them — a law that renders the split
// where it does not belong breaks it.
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
  localparam pk::in_t S1 = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
