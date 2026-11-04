// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, input logic [7:0] d, output logic [7:0] a);
  function automatic logic [7:0] inc(input logic [7:0] v);
    return v + 1;
  endfunction
  task go();
    a = inc(d);
    $display("%0d %0d", a, d);
    $write(d);
    fork
      begin a = d; end
      #1 a = 0;
    join_none
  endtask
endinterface
module top;
  logic clk;
  logic [7:0] d, a;
  bfm u(.clk(clk), .d(d), .a(a));
endmodule
