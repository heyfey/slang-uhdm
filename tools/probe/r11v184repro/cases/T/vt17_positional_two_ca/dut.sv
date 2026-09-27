// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: a positional type override; the child's continuous assignments write a select of T and a whole T port
module sub #(parameter type T = logic) (input T si, output T so, output logic o);
  T r;
  assign r[0] = si[1];
  assign so = si;
  assign o = r[0];
endmodule
module top(output logic [1:0] c, output logic d);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p, q;
  sub #(ie_t) v (p, q, d);
  assign c = q;
endmodule
