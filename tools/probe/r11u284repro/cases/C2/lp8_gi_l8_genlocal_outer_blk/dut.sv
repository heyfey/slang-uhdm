// § genCaCatMemberInst284
module dut(input logic a, output logic [31:0] o);
  localparam logic [7:0] P = 8'd3;
  if (1) begin : g
    logic [31:0] lv;
    if (1) begin : g2
      assign lv = {P, 1'b0};
    end
    assign o = lv;
  end
endmodule
