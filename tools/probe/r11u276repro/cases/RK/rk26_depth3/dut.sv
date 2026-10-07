// § caReduceOpKindGate276
module leaf #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, n2, output logic [7:0] o);
  assign o = (P | n) ^ (n2 & P);
endmodule
module mid #(parameter logic [7:0] P = 8'h1) (input logic [7:0] n, n2, output logic [7:0] o);
  leaf #(.P(P)) l (.n(n), .n2(n2), .o(o));
endmodule
module dut (input logic [7:0] n, n2, output logic [7:0] o);
  mid #(.P(8'h77)) m (.n(n), .n2(n2), .o(o));
endmodule
