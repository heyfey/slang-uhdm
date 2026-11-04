// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [7:0] P = 8'd3;
  logic [31:0] w;
  case (1) 1: begin : g
    logic [31:0] lv;
    assign lv = {P, 1'b0};
    assign o = lv;
  end default: begin : h end endcase
endmodule
