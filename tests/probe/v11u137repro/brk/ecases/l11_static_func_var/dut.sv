// § elabCloneFullNameUnstored137
module dut(input logic clk, output int c);
  function int cnt();
    static int n = 0;
    n++;
    return n;
  endfunction
  always_ff @(posedge clk) c <= cnt();
endmodule
module top(input logic clk, output int c);
  dut u(.clk(clk), .c(c));
endmodule
