// The imported parameter's name collides with a MODULE name and a TASK name.
package pv29;
  parameter int thing = 29;
endpackage
import pv29::*;
module thing;
  int q;
endmodule
module top_v29;
  thing u();
  int z;
  task automatic thing_t(); endtask
  initial z = thing;
endmodule
