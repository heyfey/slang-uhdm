// § bitsDefNoFoldNoTs421
module top #(parameter w_p = 4) (output logic [7:0] o);
  typedef logic [w_p-1:0] t_t;
  localparam W = $bits(t_t);
  localparam X = W * 2;
  localparam logic [7:0] Y = $bits(t_t);
  assign o = X + Y;
endmodule
