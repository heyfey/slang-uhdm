// § incDecMemberSelIsLvalue184 § incDecSelTopRestore184v: inc/dec member selects with a unary index in a module function and a task (the operand pointer across a nested unary operator)
typedef struct packed { logic [7:0] f; } s_t;
module top;
  s_t s;
  function automatic void bump(int j);
    s.f[~j]++;
    --s.f[-j];
  endfunction
  task automatic tb(logic c);
    s.f[!c]--;
  endtask
endmodule
