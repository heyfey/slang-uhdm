// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
class c;
  static task t(input s_t y, output s_t z); z = y; endtask
endclass
module top;
  task g(input s_t y, output s_t z); z = y; endtask
  s_t r, q;
  initial g(r, q);
endmodule
