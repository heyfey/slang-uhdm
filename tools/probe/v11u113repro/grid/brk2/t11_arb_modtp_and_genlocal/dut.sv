module top #(parameter type idx_t = logic [1:0]) (input logic a, output logic [1:0] y, output logic [2:0] z);
  if (1) begin : g
    localparam type w_t = logic [2:0];
    assign y = idx_t'(a);
    assign z = w_t'(a);
  end
endmodule
