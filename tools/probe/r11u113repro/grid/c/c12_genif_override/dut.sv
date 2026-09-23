module c #(parameter type idx_t = logic [1:0]) (input logic a, output logic [2:0] y);
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule
module top (input logic a, output logic [2:0] y);
  c #(.idx_t(logic [2:0])) u (.a(a), .y(y));
endmodule
