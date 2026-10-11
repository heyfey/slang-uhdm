// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [7:0] P = 8'd3;
  logic [31:0] m [2];
  assign o = m[0] ^ m[1];
  if (1) begin : g
    assign m[0] = {P, 1'b0};
  end
  assign m[1] = 0;
endmodule
