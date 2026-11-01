// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  string s;
  int n;
  task run();
    s = $sformatf("%0d", data);
    $cast(n, data);
    if ($isunknown(data)) n = 0;
    n = $countones(data);
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule
