// § tfArgTypeParamDefaultWriter231 — the default is an alias of an enum typedef
package p;
  typedef enum {A0, A1, A2} e_t;
  typedef e_t e2_t;
  class wrap #(type T=e2_t);
    function void put(T v);
    endfunction
  endclass
endpackage
module top;
endmodule
