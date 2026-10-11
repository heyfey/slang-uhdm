// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  if (1) begin : g
    logic [31:0] lv;
    if (1) begin : h
      logic [31:0] lw;
      assign lw = {P, a};
      assign lv = lw;
    end
    assign o = lv;
  end
endmodule
