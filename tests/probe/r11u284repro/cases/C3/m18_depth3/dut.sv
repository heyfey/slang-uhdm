// § genCaCatMemberInst284
module k3(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  if (1) begin : g
    logic [31:0] lv;
    assign lv = {P, a};
    assign o = lv;
  end
endmodule
module k2(input logic a, output logic [31:0] o);
  k3 u3 (.a(a), .o(o));
endmodule
module dut(input logic a, output logic [31:0] o);
  k2 u2 (.a(a), .o(o));
endmodule
