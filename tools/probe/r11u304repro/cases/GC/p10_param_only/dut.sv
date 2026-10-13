// § genCaCastTdAliasScopedName304
module top #(parameter int P = 1)(input logic [7:0] x, output logic [7:0] o[4], q);
  typedef logic [7:0] b_t;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = (b_t'(x)) + (int'(i));
  end
  assign q = 0;
endmodule
