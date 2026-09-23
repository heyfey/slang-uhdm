module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, output logic [1:0] y, output logic [1:0] z);
  assign y = idx_t'(a);
  assign z = '0;
endmodule
