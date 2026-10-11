// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam P = 3;
  logic [31:0] w;
  assign o = w;
  for (genvar i = 0; i < 1; i++) begin : g
    if (1) begin : g2
    assign w[i] = {P, 1'b0};
    end
  end
endmodule
