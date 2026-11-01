// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  int n;
  function int f(int x);
    return x + n;
  endfunction
  task run(input int k);
    n = f(data);
    n = f(f(k) + data);
    $display("%0d", f(n));
  endtask
endinterface
module top;
  logic clk;
  bfm u(.clk(clk));
endmodule
