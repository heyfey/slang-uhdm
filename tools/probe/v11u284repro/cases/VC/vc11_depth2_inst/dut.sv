// § genCaCatMemberInst284
module leaf(input logic a, output logic [31:0] o);
  localparam logic [63:0] P = 1;
  logic [31:0] w;
  assign w[31:8] = 0;
  assign o = w;
  if (1) begin : g
    assign w[7:0] = {a, P};
  end
endmodule
module mid(input logic a, output logic [31:0] o);
  leaf l(.a(a), .o(o));
endmodule
module dut(input logic a, output logic [31:0] o);
  mid m(.a(a), .o(o));
endmodule
