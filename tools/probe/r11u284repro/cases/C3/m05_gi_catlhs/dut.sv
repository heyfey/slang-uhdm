// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  logic [15:0] x, y;
  assign o = {x, y};
  if (1) begin : g
    assign {x, y} = {P, a};
  end
endmodule
