// § formalDefaultNamedThroughFormal191: defaults naming two earlier formals and a qualified package constant, a formal's bit select and a struct formal's member, in a module task and function
package pk;
  parameter int K = 5;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
endpackage
module top(output int o);
  task automatic t(int a, int b, int c = a * b + pk::K);
  endtask
  function automatic int f(logic [3:0] a, logic b = a[0], pk::s_t s = 8'h12, int d = s.x);
    return a + b + d;
  endfunction
  initial t(1, 2);
  assign o = f(4'h3, 1'b1, 8'h34, 2);
endmodule
