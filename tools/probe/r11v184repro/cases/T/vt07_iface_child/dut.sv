// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: an interface with a type parameter overridden by a module enum, with and without a whole-signal continuous assignment
interface bus #(parameter type T = logic) (input T si);
  T r;
  T w;
  assign w = si;
  always_comb r = si;
endinterface
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1, I2} ie_t;
  ie_t p;
  bus #(.T(ie_t)) b (.si(p));
  assign c = b.r;
endmodule
