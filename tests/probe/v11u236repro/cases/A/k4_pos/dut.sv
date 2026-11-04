// § namedCallArgFormalTs236 — actual kinds of a pos call in a continuous assignment (fresh: literal, call, enum constant, parameter)
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
  typedef enum int {E0, E1} e_t;
endpackage
module top import p::*; #(parameter int P = 3) (input int a, input int b, output int o);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  assign o = h(a, P);
endmodule
