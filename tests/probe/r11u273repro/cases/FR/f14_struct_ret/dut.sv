// § fnRetLitRhsSharesDefConst273
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  assign o = f(a);
  function automatic s_t f(input logic [7:0] address);
    if (PD) return s_t'(address);
    else return '1;
  endfunction
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  m u0(.a(a), .o(o));
endmodule
