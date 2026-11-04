// § modAggTfArgCloneFollows180 (r11u190: a module typedef typing a NON-ANSI port and a task input formal; the module instantiated)
module sub(x, y);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } op_t;
  input op_t x;
  output logic [1:0] y;
  task automatic t(input op_t v, output logic [1:0] r); r = v.a; endtask
  always_comb t(x, y);
endmodule
module top(input logic [3:0] i, output logic [1:0] o);
  sub u(.x(i), .y(o));
endmodule
