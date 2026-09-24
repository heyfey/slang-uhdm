module top(input logic clk, input logic [31:0] a, input logic [3:0] idx, output logic [31:0] o);
  if (1) begin : gb
    logic [31:0] gpr [0:15];
    logic [31:0] loc;
    always_ff @(posedge clk) gpr[idx] <= a;
    assign loc = gpr[idx];
  end
  assign o = a;
endmodule
