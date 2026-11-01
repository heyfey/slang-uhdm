// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, input logic ok);
  logic [3:0] arr [3];
  task chk();
    assert (ok) else $error("bad %0d", arr[0]);
    assert (arr[1] == 0);
    foreach (arr[k]) wait (arr[k] != 0);
  endtask
endinterface
module top;
  logic clk, ok;
  bfm u(.clk(clk), .ok(ok));
endmodule
