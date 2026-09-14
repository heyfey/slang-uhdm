// a18 — THE DIVISIBILITY BAIL ON THE NON-NESTED ROAD.  A FIRST-LEVEL whole
// write (`c.u = UU`) into a 95-bit member: `mw % n` is 1 again, so the whole
// assembly bails and golden's elaborated Rhs stays a `struct_var`.  a3 is the
// same bail reached through § pkgStructFuncAssembleNested24's road; this one
// is reached through the plain whole-slice road.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { logic [94:0] u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam logic [94:0] S1 = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
