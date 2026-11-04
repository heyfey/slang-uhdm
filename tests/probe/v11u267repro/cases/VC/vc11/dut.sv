// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
module sha import hp::*; (input logic [15:0] i, output wire [15:0] o);
  if (1) begin : g
    wire b_t [1:0] x;
    assign x = i;
  end
  assign o = g.x;
endmodule
module top(input logic [15:0] i, output wire [15:0] o);
  sha u_s(.i(i), .o(o));
endmodule
