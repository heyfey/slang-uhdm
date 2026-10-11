// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  logic [31:0] w;
  assign o = w;
  generate if (1) begin : g
    assign w = {P, 1'b0} | {64'd0, a};
  end endgenerate
endmodule
