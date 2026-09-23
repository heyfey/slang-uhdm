module top (input logic a, output logic [1:0] y [2]);
  if (1) begin : g
    localparam type idx_t = logic [1:0];
    for (genvar k = 0; k < 2; k++) begin : h
      assign y[k] = idx_t'(a);
    end
  end
endmodule
