// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the only continuous assignment writes an output port declared as a net of a packed array of T (output wire T [1:0] so)
module sub #(parameter type T = logic) (input T si, output wire T [1:0] so);
  assign so = {si, si};
endmodule
module top (output logic [3:0] c);
  typedef enum logic [1:0] {J0, J1} je_t;
  je_t p;
  sub #(.T(je_t)) v (.si(p), .so(c));
endmodule
