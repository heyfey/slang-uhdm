// a7 — THE MEMBER WIDER, THE NON-NESTED WHOLE WRITE.  `u` is `logic [127:0]`
// and the write is FIRST-LEVEL (`c.u = UU`), so the leftover reaches the
// non-nested whole-slice assemble road rather than
// § pkgStructFuncAssembleNested24's.  `ew` = 64: each operand zero-extended to
// 64 bits, first at the MSBs — where the slice road left-pads the 64-bit
// folded value into 128.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { logic [127:0] u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam logic [127:0] S1 = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
