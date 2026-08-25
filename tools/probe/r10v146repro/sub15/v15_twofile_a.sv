// TWO files, each its own $unit import (ordering across compilation units), file A.
package pv15a;
  parameter int AONE = 61;
  parameter int ATWO = 62;
endpackage
import pv15a::*;
module top_v15a;
  int z;
  initial z = AONE + ATWO;
endmodule
