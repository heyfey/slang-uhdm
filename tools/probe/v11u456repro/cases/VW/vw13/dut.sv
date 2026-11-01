// § ifcTaskFixupWalksWait456
interface bfm #(parameter int W = 8) (input logic clk);
  logic [W-1:0] data;
  logic ok;
  task run();
    wait (ok);
    $display("%h", data);
  endtask
endinterface
module top;
  logic clk;
  for (genvar g = 0; g < 2; g++) begin : gen
    bfm #(.W(4 + g)) u(.clk(clk));
  end
endmodule
