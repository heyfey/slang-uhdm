module top #(parameter type idx_t = struct packed { logic p; logic q; }) (input logic a, output logic [1:0] y);
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule
