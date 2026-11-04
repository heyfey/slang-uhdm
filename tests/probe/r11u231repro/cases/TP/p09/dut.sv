// § tfArgTypeParamDefaultWriter231 — control: a $unit class and a $unit enum
typedef enum {A0, A1, A2} e_t;
class wrap #(type T=e_t);
  function void put(T v);
  endfunction
endclass
module top;
  wrap w;
endmodule
