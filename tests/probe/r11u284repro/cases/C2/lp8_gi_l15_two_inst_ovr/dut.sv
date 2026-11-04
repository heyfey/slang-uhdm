// § genCaCatMemberInst284
module kid #(parameter logic [7:0] P = 8'd3) (input logic a, output logic [31:0] o);
  logic [31:0] lv;
  if (1) begin : g
    assign lv = {P, a};
  end
  assign o = lv;
endmodule
module dut(input logic a, output logic [31:0] o, output logic [31:0] o2);
  kid #(.P(8'd5)) u1 (.a(a), .o(o));
  kid u2 (.a(a), .o(o2));
endmodule
