// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, input logic rst);
  logic [7:0] mem [8];
  task run(input int i);
    foreach (mem[i]) begin
      mem[i] = i;
    end
    wait (rst == 0) mem[i] = 1;
  endtask
endinterface
module top;
  logic clk, rst;
  bfm u(.clk(clk), .rst(rst));
endmodule
