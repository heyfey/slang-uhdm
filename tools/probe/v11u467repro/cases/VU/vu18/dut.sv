// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; export a::PA; endpackage
import c::*;
program prg;
  initial $display(PA);
endprogram
module top;
  logic w;
endmodule
