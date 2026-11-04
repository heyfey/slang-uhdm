// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b;
  import a::*;
endpackage
package d;
  import a::*;
endpackage
package c;
  import a::*;
  import b::*;
  import d::*;
endpackage
import a::*;
import c::*;
module top;
  logic w;
endmodule
