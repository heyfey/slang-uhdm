// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v (control): the only continuous assignment writes an output port declared as a variable of T (output T so; the landed law's shape)
module sub #(parameter type T = logic) (input T si, output T so);
  assign so = si;
endmodule
module top (output logic [1:0] c);
  typedef enum logic [1:0] {J0, J1} je_t;
  je_t p;
  wire je_t q;
  sub #(.T(je_t)) v (.si(p), .so(q));
  assign c = q;
endmodule
