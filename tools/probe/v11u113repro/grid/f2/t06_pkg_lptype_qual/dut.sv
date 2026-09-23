package pk; localparam type idx_t = logic [1:0]; endpackage
module top (input logic a, output logic [1:0] y);
  if (1) begin : g
    assign y = pk::idx_t'(a);
  end
endmodule
