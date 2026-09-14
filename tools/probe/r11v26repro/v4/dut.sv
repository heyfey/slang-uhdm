// v4 — A NESTED-PATTERN parameter read whole.  `UU`'s own pattern has a nested
// struct element, so after the producer's flatten the operand list may hold an
// OPERATION rather than a plain constant.  `memLeftPatParamClone26` DECLINES
// any operand that is not a constant — but the FLATTEN half is not gated on
// the clone succeeding, so this arm is where a half-applied law would show.
package pk;
  typedef struct packed { int unsigned x; int unsigned y; } n_t;
  typedef struct packed { n_t a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: '{x: 1, y: 2}, b: 3};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::in_t S = P.u;
  localparam pk::n_t  T = P.u.a;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
