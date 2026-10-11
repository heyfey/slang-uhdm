// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  logic [31:0] w;
  assign o = w;
  for (genvar i = 0; i < 1; i++) begin : g
    logic [31:0] lv;
    assign lv = {P, a};
    assign w = lv;
  end
endmodule
