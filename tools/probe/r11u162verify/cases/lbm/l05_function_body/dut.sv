// § lvPathBaseAtFirstMember154
module top(input logic [3:0] x, output logic [15:0] o);
  typedef struct packed { logic [7:0] wdtxx; logic [7:0] q; } s_t;
  function automatic s_t f(logic [3:0] y);
    s_t t;
    t = '0;
    t.wdtxx[3:0] = y;
    return t;
  endfunction
  assign o = f(x);
endmodule
