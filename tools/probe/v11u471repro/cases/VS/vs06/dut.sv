// § enumSharedCloneHomeInst471
// control: anonymous enum parameter shared by two importers
package a;
  parameter enum {U0, U1, U2} PU = U2;
endpackage
package b; import a::*; endpackage
package c; import a::*; endpackage
module top(output int y);
  assign y = 1;
endmodule
