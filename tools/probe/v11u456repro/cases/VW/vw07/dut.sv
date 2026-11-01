// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  logic ok;
  task run();
    assert (ok) else $error("bad %0d", data);
    assume (data != 0);
    cover (ok && data == 1);
    assert #0 (data > 0);
    assert final (ok);
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule
