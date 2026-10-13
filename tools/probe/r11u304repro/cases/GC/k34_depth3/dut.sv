// § genCaCastTdAliasScopedName304
module leaf (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule
module mid (input logic a, output logic [1:0] y);
  leaf l(.a(a), .y(y));
endmodule
module top (input logic a, output logic [1:0] y);
  mid m(.a(a), .y(y));
endmodule
