// § genCaCatMemberInst284
module kid #(parameter logic [63:0] P = 1) (input logic a, output logic [31:0] o);
  if (1) begin : g
    logic [31:0] lv;
    assign lv = {P, a};
    assign o = lv;
  end
endmodule
module dut(input logic a, output logic [31:0] o, output logic [31:0] o2);
  kid #(.P(64'd5)) u1 (.a(a), .o(o));
  kid u2 (.a(a), .o(o2));
endmodule
