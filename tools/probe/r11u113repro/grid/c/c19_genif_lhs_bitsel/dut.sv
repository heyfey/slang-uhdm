module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, output logic [1:0] y, output logic [1:0] z);
  logic [1:0] n [2];
  if (W == 2) begin : g
    assign n[0] = idx_t'(a);
  end
  assign y = n[0];
  assign z = '0;
endmodule
