// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  if (1) begin : g
    assign iw = {P, a};
  end
  assign o = g.iw;
endmodule
