// r10buvm11 arm w5 — the PARAMETERIZED class property, i.e. the shape
// § assocTypeParamDimIsStaticSize51 reshapes (`T pool[KEY]` -> a STATIC array
// carrying one `[0:KEY-1]` range).  It is the one class-scope path that reaches
// `av->Ranges(...)` through a THIRD producer, so the law has to be measured
// there and not assumed from the other two.  MEASUREMENT ONLY.
package pk11d;
  class w5_pool #(type KEY = int, type T = bit);
    T    pool [KEY];
    bit  bpool[KEY];
    int  ipool[KEY];
  endclass
  class w5_use;
    w5_pool #(int, bit)    a;
    w5_pool #(string, int) b;
  endclass
endpackage
module w5v_param11_top;
  pk11d::w5_use u = new();
endmodule
