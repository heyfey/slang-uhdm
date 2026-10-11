// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o [2]);
  localparam logic [63:0] P = 1;
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = {P, a};
  end
endmodule
