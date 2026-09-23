// case item in a class method inside a module (unusual) -- class in package reading imported param
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; endpackage
package pc; import pk::*;
  class C; function int f(logic [7:0] v); case (v) P: return 1; default: return 0; endcase endfunction endclass
endpackage
module top (input logic [7:0] x, output int y); initial begin pc::C c = new; y = c.f(x); end endmodule
