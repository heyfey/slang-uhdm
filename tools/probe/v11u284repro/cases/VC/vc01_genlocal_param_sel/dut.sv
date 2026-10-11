// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  logic [31:0] w;
  assign w[31:8] = 0;
  assign o = w;
  if (1) begin : g
    localparam logic [63:0] Q = 1;
    assign w[7:0] = {Q, a};
  end
endmodule
