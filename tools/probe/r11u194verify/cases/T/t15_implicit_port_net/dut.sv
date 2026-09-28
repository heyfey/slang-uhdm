// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: an output port declared with the type only and the default net type made explicit by `default_nettype (output T so is a variable; this is the control) beside a net-typed input
`default_nettype wire
module sub #(parameter type T = logic) (input wire T si, output T so);
  assign so = si;
endmodule
module top (output logic [1:0] c);
  typedef enum logic [1:0] {J0, J1} je_t;
  je_t p;
  wire je_t q;
  sub #(.T(je_t)) v (.si(p), .so(q));
  assign c = q;
endmodule
