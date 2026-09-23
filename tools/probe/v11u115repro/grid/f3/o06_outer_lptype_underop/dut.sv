module top (input logic a, output logic [1:0] y);
  if (1) begin : g
    localparam type idx_t = logic [1:0];
    if (1) begin : h
      assign y = idx_t'(a) + 2'd1;
    end
  end
endmodule
