module sub #(parameter type idx_t = logic [1:0]) (input logic a, output logic [7:0] y);
  assign y = idx_t'(a);
endmodule
module dut (input logic a, output logic [7:0] y, output logic [7:0] z);
  sub #(.idx_t(logic [3:0])) u (.a(a), .y(y));
  sub u2 (.a(a), .y(z));
endmodule
