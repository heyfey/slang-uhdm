// pkg B imports and EXPORTS pkg A wholesale; $unit imports B.
package pv8a;
  parameter int AA = 51;
endpackage
package pv8b;
  import pv8a::*;
  export pv8a::*;
  parameter int BB = 52;
endpackage
import pv8b::*;
module top_v8;
  int z;
  initial z = BB;
endmodule
