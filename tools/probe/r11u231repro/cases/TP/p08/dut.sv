// § tfArgTypeParamDefaultWriter231 — a module specializes the class with another enum
package p;
  typedef enum {A0, A1, A2} e_t;
  typedef enum {B0, B1} f_t;
  class wrap #(type T=e_t);
    static function void put(T v);
    endfunction
  endclass
endpackage
module top;
  initial p::wrap#(p::f_t)::put(p::B1);
endmodule
