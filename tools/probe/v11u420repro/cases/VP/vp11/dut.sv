// § ansiNoDirNetPortUntyped420
module top(wire [3:0] b, input logic c);
  assign b = {4{c}};
endmodule
