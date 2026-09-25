// § lvPathBaseAtFirstMember154
module top(input logic clk, input logic [3:0] x, output logic [7:0] o);
  typedef struct packed { logic [7:0] wdtxx; } s_t;
  function automatic s_t f(input logic [3:0] a);
    s_t r; r = '0; r.wdtxx[3:0] = a; return r;
  endfunction
  assign o = f(x).wdtxx;
endmodule
