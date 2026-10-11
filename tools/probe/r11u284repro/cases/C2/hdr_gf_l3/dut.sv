// § genCaCatMemberInst284
module dut #(parameter int P = 3) (input logic a, output logic [31:0] o);
  logic [31:0] w;
  assign o = w;
  for (genvar i = 0; i < 2; i++) begin : g
    assign w[i] = {P, 1'b0};
  end
endmodule
