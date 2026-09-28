// § lvIdxCallArgIsRead198
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  int qa [2][$];
  logic [7:0] arr;
  always @(posedge clk) begin
    arr[qa[k].size()] <= 1'b1;
  end
  assign o = arr;
endmodule
