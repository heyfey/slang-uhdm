// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  logic [31:0] w;
  assign o = w;
  for (genvar k = 0; k < 2; k++) begin : gf
    if (1) begin : gi
      assign w[k*8 +: 8] = {P, a};
    end
  end
  assign w[31:16] = 0;
endmodule
