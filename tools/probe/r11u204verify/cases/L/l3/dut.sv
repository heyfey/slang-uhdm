// § lvIdxCallArgIsRead198: a call over a local struct's member in an lvalue index inside a function's for loop and a task body
module top (input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  function automatic logic [7:0] fn(input s_t s);
    logic [7:0] r;
    r = '0;
    for (int i = 0; i < 2; i++) r[fx(s.f[i])] = 1'b1;
    return r;
  endfunction
  task automatic tk(input s_t s, output logic [7:0] q);
    q = '0;
    q[fx(s.f[1])] = 1'b1;
  endtask
  assign o = fn('0);
endmodule
