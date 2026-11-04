// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  logic ok;
  task run();
    wait (ok);
    data = 3;
  endtask
endinterface
module top;
  logic clk;
  bfm u1(.clk(clk));
  bfm u2(.clk(clk));
  bfm u3(.clk(clk));
endmodule
