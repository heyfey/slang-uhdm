// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  if (1) begin : g
    logic [31:0] lv;
    assign lv = ~{P, a};
    assign o = lv;
  end
endmodule
