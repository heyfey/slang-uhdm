// § taskNameReadImplicitNet451
package p; task pt; endtask endpackage
module m #(parameter P) (input clk);
  import p::*;
  initial $display("%b", pt);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
