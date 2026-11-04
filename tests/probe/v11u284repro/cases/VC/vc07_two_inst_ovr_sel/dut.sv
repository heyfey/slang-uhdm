// § genCaCatMemberInst284
module sub #(parameter logic [63:0] P = 1) (input logic a, output logic [31:0] o);
  logic [31:0] w;
  assign w[31:8] = 0;
  assign o = w;
  if (1) begin : g
    assign w[7:0] = {P, a};
  end
endmodule
module dut(input logic a, output logic [31:0] o1, o2);
  sub #(.P(64'd5)) u1(.a(a), .o(o1));
  sub u2(.a(a), .o(o2));
endmodule
