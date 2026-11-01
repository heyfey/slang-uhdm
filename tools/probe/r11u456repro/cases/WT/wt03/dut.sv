// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, input logic reset);
  logic [3:0] cnt;
  task t();
    wait (reset == 0);
    cnt = 4'd1;
  endtask
endinterface
module top;
  logic clk, reset;
endmodule
