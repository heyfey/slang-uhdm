// § callArgVarSelStamp198
module top (input logic c, input logic [3:0] p [2][4], output logic [3:0] y);
  typedef logic [3:0] n_t;
  function automatic n_t f(input n_t x); return ~x; endfunction
  assign y = f(p[1][3]);
endmodule
