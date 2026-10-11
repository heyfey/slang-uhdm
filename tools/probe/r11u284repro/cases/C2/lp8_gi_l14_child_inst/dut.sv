// § genCaCatMemberInst284
module kid(input logic a, output logic [31:0] o);
  localparam logic [7:0] P = 8'd3;
  logic [31:0] w;
  assign o = w;
  if (1) begin : g
    assign w[8:0] = {P, a};
  end
endmodule
module dut(input logic a, output logic [31:0] o);
  kid u (.a(a), .o(o));
endmodule
