// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  logic go;
  task run();
    fork
      begin
        int k = data;
        $display("%0d", k);
      end
      begin
        wait (go);
        data = 0;
      end
    join_any
    disable fork;
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule
