// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam P = 3;
  logic [31:0] w;
  if (1) begin : g
    logic [31:0] lv;
    assign lv = {P, 1'b0};
    assign o = lv;
  end
endmodule
