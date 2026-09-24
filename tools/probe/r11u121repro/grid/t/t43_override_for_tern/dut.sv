module sub #(parameter type idx_t = logic [1:0]) (input logic a, b, s, output logic [7:0] n [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign n[k] = s ? idx_t'(a) : idx_t'(b);
  end
endmodule
module dut (input logic a, b, s, output logic [7:0] n [2], output logic [7:0] m [2]);
  sub #(.idx_t(logic [3:0])) u (.a(a), .b(b), .s(s), .n(n));
  sub u2 (.a(a), .b(b), .s(s), .n(m));
endmodule
