// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, input logic rst_n, output logic [7:0] a);
  logic busy;
  task go();
    wait (rst_n) a = 8'h2;
    wait (!busy && rst_n) begin
      a = a + 1;
      busy = 1'b1;
    end
  endtask
  function automatic void clr();
    busy = 0;
  endfunction
endinterface
module top;
  logic clk, rst_n;
  logic [7:0] a, b;
  bfm u1(.clk(clk), .rst_n(rst_n), .a(a));
  bfm u2(.clk(clk), .rst_n(rst_n), .a(b));
endmodule
