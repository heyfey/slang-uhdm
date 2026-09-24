// v9 — THE SELECTIVITY CONTROL.  Two pattern parameters of the same type in
// the same package; the builder reads ONLY `UU`.  `VV` has no reader at all,
// so it must keep its tagged tree (the m10 answer) while `UU` flattens.  A
// predicate that answered per-SCOPE rather than per-SYMBOL would flatten both.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  localparam in_t VV = '{a: 33, b: 44};
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
