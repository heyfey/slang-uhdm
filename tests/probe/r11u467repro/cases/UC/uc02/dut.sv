// § unitCopyOwnTsEveryPath467
package a;
  typedef bit [3:0] nib_t;
  parameter nib_t PA = 4'd3;
  parameter int PI = 7;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
  import b::*;
endpackage
import c::*;
module top;
  logic w;
endmodule
