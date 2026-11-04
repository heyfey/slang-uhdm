// § genCaCastTdAliasScopedName304
module top (input logic [3:0] x, output logic [3:0] o);
  typedef logic [1:0] b_t;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[2*i+1:2*i] = b_t'(x[2*i+1:2*i]);
  end
endmodule
