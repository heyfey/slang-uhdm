// § genCaCastTdAliasScopedName304
module top (input logic [1:0] a, output logic [1:0] y);
  typedef enum logic [1:0] {A, B, C} e_t;
  if (1) begin : g
    assign y = e_t'(a);
  end
endmodule
