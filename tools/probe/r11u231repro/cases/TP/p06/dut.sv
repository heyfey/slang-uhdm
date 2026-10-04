// § tfArgTypeParamDefaultWriter231 — a package function writes the definition listing, the class the elaborated one
package p;
  typedef enum {A0, A1, A2} e_t;
  function automatic int f(e_t x);
    return int'(x);
  endfunction
  class wrap #(type T=e_t);
    function void put(T v);
    endfunction
  endclass
endpackage
module top(output int o);
  assign o = p::f(p::A1);
endmodule
