// § caReduceOpKindGate276
module kid #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, n2, output logic [7:0] o);
  assign o = (P & n) ^ n2;
endmodule
module dut (input logic [7:0] n, n2, output logic [7:0] o, o2);
  kid #(.P(8'h11)) u1 (.n(n), .n2(n2), .o(o));
  kid u2 (.n(n), .n2(n2), .o(o2));
endmodule
