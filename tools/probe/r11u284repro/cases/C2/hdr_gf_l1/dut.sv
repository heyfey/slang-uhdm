// § genCaCatMemberInst284
module dut #(parameter int P = 3) (input logic a, output logic [31:0] o);
  logic [31:0] w;
  assign o = w;
  for (genvar i = 0; i < 2; i++) begin : g
    logic [31:0] lv;
    assign lv = {P, 1'b0};
    assign w[i] = lv[0];
  end
endmodule
