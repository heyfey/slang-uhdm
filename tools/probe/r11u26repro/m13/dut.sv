// m13 — THE WIDTH RULE BESIDE THE NEW TRIGGER.  `w_t` is 128 bits, so the
// landed WIDTH rule (ParamEmit ~12338: a package struct-pattern parameter
// wider than 64 bits keeps its tagged_pattern tree in the ELAB view) would
// keep `WW` tagged — while the builder reads it WHOLE.  This arm says which
// rule golden follows.
package pk;
  typedef struct packed { logic [63:0] a; logic [63:0] b; } w_t;
  typedef struct packed { w_t u; int unsigned d; } c_t;
  localparam w_t WW = '{a: 64'h11, b: 64'h22};
  function automatic c_t mk();
    c_t c; c.u = WW; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::w_t S = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
