// m12 — THE LEFTOVER LAW, ISOLATED FROM THE FLATTEN.  m1 plus one scoped,
// member-selecting read of UU elsewhere in the source, which makes OUR OWN
// landed flat-walk (§ SCOPED-REFERENCE / MEMBER-SELECT rules, ParamEmit ~12380
// and ~12408) flatten UU's elaborated Rhs on the pristine binary too.  So the
// ONLY judge-visible difference left on this arm is the typespec_member
// leftover itself.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
  localparam int unsigned AA = UU.a;   // <- the MEMBER-SELECT trigger, in the package
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
