// § tfArgTypeParamDefaultWriter231 — a nested class reads its outer class's type parameter
package p;
  typedef enum {A0, A1, A2} e_t;
  class outer #(type T=e_t);
    class inner;
      function void put(T v);
      endfunction
    endclass
  endclass
endpackage
module top;
endmodule
