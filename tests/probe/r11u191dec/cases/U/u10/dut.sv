// (r11u191) control: an uninstantiated reader keeps the parameter's width in its definition
package p;
   parameter logic [15:0] X = 16'h12;
endpackage
module m2(output int a);
   import p::X;
   assign a = X;
endmodule
module top(output int o);
   assign o = 1;
endmodule
