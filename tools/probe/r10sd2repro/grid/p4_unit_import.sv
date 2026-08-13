// p4 — a $unit-scope import (the shape SeqDriver's testbench.sv uses on line 1).
package p4a;
  parameter int P4 = 7;
  typedef int p4_t;
endpackage
import p4a::*;
module top;
  int x = P4;
  p4_t y;
  initial $display("%0d %0d", x, y);
endmodule
