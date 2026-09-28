// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the whole-signal continuous assignment writes an output port declared as a NET of T (wire), and another writes a T net declared in the body with a net declaration assignment
module sub #(parameter type T = logic) (input T si, output wire T so);
  wire T w = si;
  assign so = w;
endmodule
module top (output logic [1:0] c);
  typedef enum logic [1:0] {J0, J1} je_t;
  je_t p;
  wire je_t q;
  sub #(.T(je_t)) v (.si(p), .so(q));
  assign c = q;
endmodule
