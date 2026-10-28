// control: a qualified package variable read outside a variable initializer (strict equal on pristine)
package c;
  int vc;
endpackage
module top;
  wire [31:0] y = c::vc;
endmodule
