// § unitCopyOwnTsEveryPath467
package a;
  parameter PU = 3;
  parameter PH = 'h1f;
  parameter [7:0] PR8 = 8'd200;
endpackage
package b; import a::*; endpackage
package c; import b::*; import a::*; endpackage
import c::*;
module top;
  logic w;
endmodule
