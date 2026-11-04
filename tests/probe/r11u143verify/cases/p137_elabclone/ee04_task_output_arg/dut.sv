// § elabCloneFullNameUnstored137
// case ee04: a sub-module task with an output argument called from an initial block
module sub(output int r);
  task automatic dbl(input int a, output int b); b = a * 2; endtask
  initial begin
    int t;
    dbl(3, t);
    r = t;
  end
endmodule
module top(output int r); sub u(.r(r)); endmodule
