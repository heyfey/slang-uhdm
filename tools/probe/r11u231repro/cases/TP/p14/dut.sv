// § tfArgTypeParamDefaultWriter231 — an extern prototype with an out-of-body definition
package p;
  typedef enum {A0, A1, A2} e_t;
  class wrap #(type T=e_t);
    extern function void put(T v);
  endclass
  function void wrap::put(T v);
  endfunction
endpackage
module top;
endmodule
