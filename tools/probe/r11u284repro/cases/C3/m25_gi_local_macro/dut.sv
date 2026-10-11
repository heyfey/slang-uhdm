// § genCaCatMemberInst284
`define CAT(x) {x, a}
module dut(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  if (1) begin : g
    logic [31:0] lv;
    assign lv = `CAT(P);
    assign o = lv;
  end
endmodule
