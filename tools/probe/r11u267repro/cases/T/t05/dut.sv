// § typedefDimNetDropsDims267
typedef logic [3:0] uw_t;
module sha (input uw_t [1:0] a);
endmodule
module top(input [7:0] a);
  sha u_s(.a(a));
endmodule
