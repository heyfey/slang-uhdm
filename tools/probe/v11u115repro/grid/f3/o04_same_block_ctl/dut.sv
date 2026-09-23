module top (input logic a, output logic [1:0] y);
  if (1) begin : g
    localparam type idx_t = logic [1:0];
    assign y = idx_t'(a);
  end
endmodule
