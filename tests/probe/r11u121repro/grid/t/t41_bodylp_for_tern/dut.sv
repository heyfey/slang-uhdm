module dut #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, input logic [3:0] v, output logic [7:0] y, output logic [7:0] n [2]);
  localparam type lt_t = logic [2:0];
  for (genvar k = 0; k < 2; k++) begin : g
    assign n[k] = s ? lt_t'(a) : lt_t'(b);
  end
  assign y = 0;
endmodule
