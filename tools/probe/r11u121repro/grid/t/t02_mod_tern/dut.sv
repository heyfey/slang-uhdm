module dut #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, input logic [3:0] v, output logic [7:0] y, output logic [7:0] n [2]);
  assign y = s ? idx_t'(a) : idx_t'(b);
  assign n[0] = 0; assign n[1] = 0;
endmodule
