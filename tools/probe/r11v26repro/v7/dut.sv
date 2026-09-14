// v7 — SYMBOLIC MEMBER DIM plus a builder read.  The new trigger is gated on
// `!structHasSymbolicMemberDim`, so it must NOT fire; Surelog leaves the
// pattern op untyped and never flattens.  The DRAIN's clone is not gated on
// the symbolic dim, so this arm also asks what the leftover is when the
// parameter's own listing keeps its tagged wrappers.
package pk;
  localparam int unsigned N = 4;
  typedef struct packed { logic [N-1:0] a; logic [N-1:0] b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 4'd11, b: 4'd2};
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
