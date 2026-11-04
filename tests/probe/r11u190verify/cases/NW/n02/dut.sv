// § newLhsBitSelAtIndex181 (r11u190: a queue element in a MODULE task, a two-dimensional element with a call index)
class R;
  int a;
  function new(int x); a = x; endfunction
endclass
module top;
  R q [$];
  R h [2][3];
  function automatic int f(int x); return x; endfunction
  task automatic mk(int i, int j);
    q.push_back(null);
    q[0] = new(i);
    h[f(i)][j] = new(j);
  endtask
  initial mk(1, 2);
endmodule
