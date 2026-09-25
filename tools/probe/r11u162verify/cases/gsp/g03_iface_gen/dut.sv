// § genScopeProcPsNamedByScope154
interface tif (input logic clk);
  logic [3:0] a;
  if (1) begin : gi
    logic [3:0] v;
    always @(posedge clk) v[2:1] <= a[1:0];
  end
endinterface
module top(input logic clk); tif t(clk); endmodule
