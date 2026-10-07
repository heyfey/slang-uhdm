// § caReduceOpKindGate276
module sub #(parameter logic [7:0] P = 8'h01) (input logic [7:0] n, m, output logic [7:0] o);
  assign o = (P & n) ^ m;
endmodule
module dut (input logic [7:0] n, m, output logic [7:0] o);
  localparam logic [7:0] A = 8'h0F;
  sub #(.P(A ^ 8'hF0)) u (.n(n), .m(m), .o(o));
endmodule
