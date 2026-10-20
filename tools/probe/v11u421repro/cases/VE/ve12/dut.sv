// § expectActionBlockStmts421
module top(input logic clk, a, b);
  class C;
    int n;
    task t();
      expect (@(posedge clk) a ##1 b) n = 1; else n = 2;
    endtask
  endclass
endmodule
