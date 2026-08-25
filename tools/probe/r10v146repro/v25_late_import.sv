// The $unit import is written AFTER the module that uses it, and the package
// after that again.
module top_v25;
  int z;
  initial z = LATE_P;
endmodule
import pv25::*;
package pv25;
  parameter int LATE_P = 55;
endpackage
