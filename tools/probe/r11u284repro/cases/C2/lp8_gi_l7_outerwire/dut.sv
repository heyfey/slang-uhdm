// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [7:0] P = 8'd3;
  wire [31:0] ow;
  assign o = ow;
  if (1) begin : g
    assign ow = {P, 1'b0};
  end
endmodule
