// § hoistPoolSourceOrder240: classes from two include files (include order against file-name order)
package hp;
`include "z_first.svh"
`include "a_second.svh"
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
