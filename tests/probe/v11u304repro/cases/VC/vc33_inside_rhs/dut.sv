// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = idx_t'(a) inside {2'd1, 2'd2};
  end
endmodule
