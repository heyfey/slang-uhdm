// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  logic [3:0] q [$];
  int n;
  task run();
    n = $bits(data);
    n = $size(q);
    $display("%0d %0d", $bits(data), $clog2(n));
    wait (n > 0);
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule
