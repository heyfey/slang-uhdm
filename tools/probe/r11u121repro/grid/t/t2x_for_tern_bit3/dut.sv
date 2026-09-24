module dut #(parameter int unsigned W = 2, parameter type idx_t = bit [2:0]) (input logic a, b, s, input logic [3:0] v, output logic [7:0] y, output logic [7:0] n [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign n[k] = s ? idx_t'(a) : idx_t'(b);
  end
  assign y = 0;
endmodule
