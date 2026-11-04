// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  wire [31:0] ow;
  assign o = ow;
  if (1) begin : g
    assign ow = {P, a};
  end
endmodule
