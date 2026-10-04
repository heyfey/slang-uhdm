// § namedCallArgFormalTs236 — a05 line 10 alone, positional (control)
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
endpackage
module top import p::*; #(parameter int P = 3) (input int a, input int b, input e_t e, output int o);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  function automatic int g(e_t x, byte_t y);
    return int'(x) + y;
  endfunction
  assign o = g(e, P) + g(E1, 8'd4);
endmodule
