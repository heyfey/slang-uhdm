// § stdRandomizeFuncCall413
module top;
  typedef struct { int f; } s_t;
  s_t s;
  int a;
  bit ok;
  task automatic t();
    ok = randomize(a);
  endtask
  initial t();
endmodule
