// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] oa[2]);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign oa[0] = idx_t'(a);
  end
  assign oa[1] = '0;
endmodule
