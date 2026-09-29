// § incDecOperandKeepsLvalueForm215 — a module struct variable's member incremented inside a function call argument, an always block and a task
module m(input logic clk, output int o);
  typedef struct { int n; int k; } s_t;
  s_t s;
  function automatic int f(int x); return x + 1; endfunction
  task automatic t(input int x); endtask
  always @(posedge clk) begin
    o <= f(s.n++);
    t(s.k--);
    o <= f(f(++s.n));
  end
endmodule
