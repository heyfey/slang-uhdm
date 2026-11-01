// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, input logic reset, output logic [7:0] a);
  task execute(input int x);
    if (reset == 1) begin
      wait (reset == 0);
    end
    wait (x == 2);
    a <= 8'h1;
  endtask
endinterface
module top;
  logic clk, reset;
  logic [7:0] a;
  bfm u(.clk(clk), .reset(reset), .a(a));
endmodule
