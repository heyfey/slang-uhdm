module dut #(parameter int unsigned W = 2, parameter type idx_t = logic [1:0][1:0]) (input logic a, b, s, input logic [3:0] v, output logic [7:0] y, output logic [7:0] n [2]);
  assign y = idx_t'(a);
  assign n[0] = 0; assign n[1] = 0;
endmodule
