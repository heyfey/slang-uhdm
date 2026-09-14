// v5 — BOTH TRIGGERS AT ONCE, and WIDE.  `WW` is 128 bits (the WIDTH rule
// says tagged), it is read as `pk::WW` somewhere (the SCOPED-REFERENCE rule
// says flat), and a builder reads it whole (the new rule says flat).  The two
// flat triggers must be idempotent, not double-applied.
package pk;
  typedef struct packed { logic [63:0] a; logic [63:0] b; } w_t;
  typedef struct packed { w_t u; int unsigned d; } c_t;
  localparam w_t WW = '{a: 64'd11, b: 64'd22};
  function automatic c_t mk();
    c_t c; c.u = WW; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::w_t Q = pk::WW,
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::w_t S = P.u;
  assign o = |Q.a & 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
