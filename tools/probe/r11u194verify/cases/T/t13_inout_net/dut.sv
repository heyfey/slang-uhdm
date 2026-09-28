// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the only continuous assignment writes an inout port declared as a net of T
module sub #(parameter type T = logic) (input T si, inout wire T io);
  assign io = si;
endmodule
module top (output logic [1:0] c);
  typedef enum logic [1:0] {J0, J1} je_t;
  je_t p;
  wire je_t q;
  sub #(.T(je_t)) v (.si(p), .io(q));
  assign c = q;
endmodule
