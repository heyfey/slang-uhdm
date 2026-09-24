module top(input logic [7:0] a, output logic [7:0] y);
  typedef struct packed { logic [3:0] h; logic [3:0] l; } s_t;
  function automatic s_t f(input logic [7:0] x); f = s_t'(x); endfunction
  assign y = f(a);
endmodule
