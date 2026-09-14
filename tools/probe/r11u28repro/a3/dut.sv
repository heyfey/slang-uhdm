// a3 — THE DIVISIBILITY BAIL.  The first-level member `u` is 95 bits and
// UU's operation carries 2 operands: `mw % n` is 1, so `assemble()` returns
// false and the WHOLE parameter's elaborated Rhs stays a `struct_var`
// (ExprEval.cpp :4996 `if (assemble(stps, bits) && !bits.empty())`, else
// `return (expr *)result`).  The bail's reach is the WHOLE struct, not the
// one member: `d` would assemble fine on its own.
// The UU write comes LAST so that r11u24's nested stamp leaves UU's OPERATION
// on `u` (a later `c.u.w = ...` would leave a plain constant and no split
// question would arise at all).
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t v; logic [30:0] w; } m95_t;      // 95 bits
  typedef struct packed { m95_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u.w = 31'd7; c.u.v = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::m95_t S1 = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
