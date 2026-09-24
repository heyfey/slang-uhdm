// § paramAliasBoundRefUnstored144
module top #(parameter int X = 4)(output int o);
  typedef logic [X-1:0] my_type_t;
  parameter my_type_t Y = 2;
  for (genvar i = 0; i < 1; i++) begin : g
    parameter my_type_t Z = 1;
    my_type_t Y;
    assign Y = Z;
  end
  assign o = int'(Y) + int'(g[0].Y);
endmodule
