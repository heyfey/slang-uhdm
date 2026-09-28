// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the only continuous assignment writes an output port declared as a net of T (output wire T so)
module sub #(parameter type T = logic) (input T si, output wire T so);
  assign so = si;
endmodule
module top (output logic [1:0] c);
  typedef enum logic [1:0] {J0, J1} je_t;
  je_t p;
  wire je_t q;
  sub #(.T(je_t)) v (.si(p), .so(q));
  assign c = q;
endmodule
