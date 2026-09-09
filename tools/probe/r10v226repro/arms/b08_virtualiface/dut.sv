// v226 b08 — an interface reached ONLY as a `virtual` type: never
// instantiated, so the new road fires; the type reference must not change that.
interface bv_if;
  logic a;
  int   q;
  initial q = 1;
  always_comb a = q[0];
endinterface

module bv_top;
  virtual bv_if vih;             // type use only, no instance
  initial vih = null;
endmodule
