// § forMultiInitAssign258 (function automatic locals, one a struct local written through its member)
module m(output int o);
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  function automatic int f(); s_t s; int i; int n = 0; for (s.a = 1, i = 0; i < 3; i++) n += s.a; return n; endfunction
  initial o = f();
endmodule
module top; int o; m u(.o(o)); endmodule
