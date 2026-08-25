// A $unit-imported parameter name colliding with an ENUM CONSTANT and with a
// VARIABLE in another scope; neither may be re-pointed.
package pv16;
  parameter int RED = 91;
endpackage
import pv16::*;
module top_v16;
  typedef enum int { GREEN = 1, BLUE = 2 } col_e;
  int RED_v;
  int z;
  initial begin
    RED_v = RED;
    z = GREEN + BLUE + RED_v;
  end
endmodule
