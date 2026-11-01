// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, input logic reset, output logic [7:0] a);
  event ev;
  logic [7:0] q[$];
  task many(input int x);
    $display("%d", a);
    ->ev;
    foreach (q[i]) a = q[i];
    fork
      a = 8'h3;
      wait (reset);
    join
    a++;
    assert (reset == 0);
    while (reset) begin wait (!reset); end
  endtask
endinterface
module top;
  logic clk, reset;
  logic [7:0] a;
  bfm u(.clk(clk), .reset(reset), .a(a));
endmodule
