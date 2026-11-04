// § incDecOperandKeepsLvalueForm215 — (r11u218 independent grid of r11u215's law) d08_module_func_arg: a module function argument, struct path
module top(output int o);
  typedef struct { int cnt; } s_t;
  s_t sp;
  function automatic int f(int a);
    return a;
  endfunction
  initial o = f(sp.cnt++);
endmodule
