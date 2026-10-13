// § genCaCastTdAliasScopedName304
module child (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule
module top (input logic a, output logic [3:0] y);
  child u0(.a(a), .y(y[1:0]));
  child u1(.a(a), .y(y[3:2]));
endmodule
