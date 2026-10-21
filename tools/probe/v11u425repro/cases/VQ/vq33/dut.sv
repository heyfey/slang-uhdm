// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
endpackage
module top(output int y);
  typedef enum int {A = p::H, B = p::O} e_t;
  e_t e = A;
  assign y = e;
endmodule
