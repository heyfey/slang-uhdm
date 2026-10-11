// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [7:0] P = 8'd3;
  logic [31:0] w;
  assign o = w;
  if (1) begin : g
    assign w[17:0] = {P, {2{P}}};
  end
endmodule
