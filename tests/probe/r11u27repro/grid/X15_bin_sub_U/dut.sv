module top(input logic [31:0] a, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = 32'b111 - 32'b11;
    assign o2 = lv;
  end
endmodule
