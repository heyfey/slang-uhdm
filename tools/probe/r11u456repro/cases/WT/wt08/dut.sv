// § ifcTaskFixupWalksWait456
module top(input logic clk, input logic reset, output logic [7:0] a);
  task execute();
    wait (reset == 0);
    $display("%d", a);
    fork a = 1; join
  endtask
  initial execute();
endmodule
