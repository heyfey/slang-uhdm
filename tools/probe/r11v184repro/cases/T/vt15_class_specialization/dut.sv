// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: a class type parameter specialized with a module enum typedef, beside a module override
class C #(type T = int);
  T v;
  function T get(); return v; endfunction
endclass
module sub #(parameter type T = logic) (input T si, output logic [1:0] o);
  T r;
  always_comb r = si;
  assign o = r;
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  C #(ie_t) h;
  sub #(.T(ie_t)) v (.si(p), .o(c));
endmodule
