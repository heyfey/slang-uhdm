package u;
  parameter int A = 4;
  localparam int B = 5;
  class base; endclass
  class pb #(type T = int) extends base; endclass
endpackage
package s;
  import u::*;
  class d1 extends base; int x; endclass
  class d2 extends pb #(int); int y; endclass
  class d3; int z; endclass
endpackage
module top; endmodule
