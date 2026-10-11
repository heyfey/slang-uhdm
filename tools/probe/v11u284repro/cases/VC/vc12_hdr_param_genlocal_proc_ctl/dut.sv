// § genCaCatMemberInst284
module dut #(parameter logic [63:0] P = 1) (input logic a, output logic [31:0] o);
  if (1) begin : g
    logic [31:0] lv;
    always_comb lv = {P, a};
    assign o = lv;
  end
endmodule
