module top (input logic a, output logic [1:0] y);
  if (1) begin : g
    typedef logic [1:0] idx_t;
    if (1) begin : h
      assign y = idx_t'(a);
    end
  end
endmodule
