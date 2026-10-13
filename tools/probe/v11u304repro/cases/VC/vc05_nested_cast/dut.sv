// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  typedef logic [2:0] w_t;
  if (1) begin : g
    assign y = idx_t'(w_t'(a));
  end
endmodule
