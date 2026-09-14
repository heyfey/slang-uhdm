// v3 — A PACKED-ARRAY pattern parameter read whole.  `PA` is not a struct, so
// the FLATTEN trigger's `structPat` gate cannot fire; the DRAIN's clone is NOT
// gated on the struct-ness of the read parameter, so this arm asks whether the
// clone fires on a shape the flatten half never sees, and whether that matches
// golden.
package pk;
  typedef logic [1:0][31:0] pa_t;
  typedef struct packed { pa_t u; int unsigned d; } c_t;
  localparam pa_t PA = '{32'd11, 32'd22};
  function automatic c_t mk();
    c_t c; c.u = PA; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::pa_t S = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
