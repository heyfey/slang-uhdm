// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  event ev;
  int q [$];
  task run();
    -> ev;
    q.push_back(data);
    data = q.pop_front();
    @(ev);
    wait (q.size() > 0);
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule
