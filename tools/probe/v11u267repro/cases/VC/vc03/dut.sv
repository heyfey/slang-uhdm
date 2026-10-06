// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
module sha import hp::*; (inout wire b_t [1:0] io, input logic en, input logic [15:0] d);
  assign io = en ? d : 'z;
endmodule
module top(inout wire [15:0] io, input logic en, input logic [15:0] d);
  sha u_s(.io(io), .en(en), .d(d));
endmodule
