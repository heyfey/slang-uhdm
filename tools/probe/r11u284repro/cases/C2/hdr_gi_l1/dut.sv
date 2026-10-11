// § genCaCatMemberInst284
module dut #(parameter int P = 3) (input logic a, output logic [31:0] o);
  logic [31:0] w;
  if (1) begin : g
    logic [31:0] lv;
    assign lv = {P, 1'b0};
    assign o = lv;
  end
endmodule
