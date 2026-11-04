// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package c;
  import a::*;
endpackage
import c::*;
module top;
  logic w;
endmodule
