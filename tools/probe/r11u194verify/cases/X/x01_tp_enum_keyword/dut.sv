// § tpEnumCopyAtTypedef184 § typeParamDefersToTpUse186 § classTpKeywordTsAtDefault188: a module type parameter with a keyword default overridden by a module enum, and a class type parameter with a keyword default specialized by the same enum
module sub #(parameter type T = int) (input T si, output T so);
  class box #(type E = int);
    E v;
    function E get(); return v; endfunction
  endclass
  box #(T) b;
  assign so = si;
endmodule
module top (output logic [1:0] c);
  typedef enum logic [1:0] {X0, X1, X2} xe_t;
  xe_t p, q;
  sub #(.T(xe_t)) v (.si(p), .so(q));
  assign c = q;
endmodule
