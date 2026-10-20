// § expectActionBlockStmts421
module top(input logic clk, a, b);
  int n;
  task t;
    expect (@(posedge clk) a |-> b) else n = 3;
  endtask
endmodule
