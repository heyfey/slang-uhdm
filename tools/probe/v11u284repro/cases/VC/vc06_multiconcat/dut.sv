// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  logic [31:0] w;
  assign w[31:8] = 0;
  assign o = w;
  if (1) begin : g
    assign w[7:0] = {2{P, a}};
  end
endmodule
