// § typedefDimNetDropsDims267
module sha #(parameter int W = 8) (input logic [2*W-1:0] i, output wire [2*W-1:0] o);
  typedef logic [W-1:0] w_t;
  wire w_t [1:0] x;
  assign x = i;
  assign o = x;
endmodule
module top(input logic [15:0] i, output wire [15:0] o, output wire [7:0] o2);
  sha u_s(.i(i), .o(o));
  sha #(.W(4)) u_t(.i(i[7:0]), .o(o2));
endmodule
