module top(input logic clk, input logic [31:0] a, output logic [31:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [31:0] src;
    logic [31:0] loc;
    always_ff @(posedge clk) src <= a;
    assign loc = src;
  end
  assign o = a;
endmodule
