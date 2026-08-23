// r10v77 -- ADVERSARIAL grid F: interface ports / modports as CONTROLS beside
// the scoped-typedef port, and an interface whose own ports carry the shape.
package f77;
  typedef logic [7:0] v8_t;
endpackage

interface ifF (input f77::v8_t fi, output f77::v8_t fo);
  f77::v8_t   body_pv;
  logic [7:0] body_plain;
  modport mp  (input fi, output fo);
  modport mp2 (input fi);
endinterface

module leafF (
  ifF.mp        m_if,
  ifF           m_ifw,
  input  f77::v8_t m_pv,
  output f77::v8_t m_pvo
);
  assign m_pvo = m_pv;
endmodule

module topF;
  logic [7:0] a, b, c, d;
  ifF u_if1 (.fi(a), .fo(b));
  ifF u_if2 (.fi(a), .fo(b));
  leafF u_f (.m_if(u_if1.mp), .m_ifw(u_if2), .m_pv(c), .m_pvo(d));
endmodule
