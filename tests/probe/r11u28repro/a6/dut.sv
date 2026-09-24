// a6 — THE MEMBER NARROWER THAN THE PATTERN.  `u` is 32 bits and UU is a
// 64-bit two-element pattern: `ew` = 16, so each operand is TRUNCATED to its
// low 16 bits (`eb.substr(eb.size() - ew)`), first operand at the MSBs.
// The whole-slice road cannot reach that: slang's folded `u` is the low 32
// bits of UU, which is 22 alone.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { logic [31:0] u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam logic [31:0] S1 = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
