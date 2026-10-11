// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  logic [31:0] m [2];
  assign o = m[0] ^ m[1];
  if (1) begin : g
    assign m[0] = {P, a};
  end
  assign m[1] = 0;
endmodule
