// § typedefDimNetDropsDims267
module sha (input logic [15:0] i, output wire [15:0] o);
  typedef logic [7:0] b_t;
  wire b_t [1:0] x = i;
  assign o = x;
endmodule
module top(input logic [15:0] i, output wire [15:0] o);
  sha u_s(.i(i), .o(o));
endmodule
