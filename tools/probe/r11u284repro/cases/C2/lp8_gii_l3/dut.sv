// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [7:0] P = 8'd3;
  logic [31:0] w;
  assign o = w;
  if (1) begin : g
    if (1) begin : g2
    assign w[3:0] = {P, 1'b0};
    end
  end
endmodule
