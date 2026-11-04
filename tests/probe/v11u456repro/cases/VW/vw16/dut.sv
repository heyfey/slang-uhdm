// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  logic ok;
  task run();
    wait fork;
    wait (ok) begin
      $display("%0d", data);
      wait (data[0]);
    end
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
  bfm v(.clk(clk));
endmodule
