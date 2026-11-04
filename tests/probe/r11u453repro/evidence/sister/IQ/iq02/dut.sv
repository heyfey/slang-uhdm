// control: a qualified package variable read outside a variable initializer (strict equal on pristine)
package c;
  int vc;
endpackage
module top;
  int y;
  assign y = c::vc;
endmodule
