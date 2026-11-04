// § procAsgRhsPkgFoldTs471
// local parameter of the module (not imported) and a $unit parameter, as whole right sides
parameter int UP = 8;
package a;
  parameter int PA = 1;
endpackage
module top(output int y, output int z, output int w);
  import a::*;
  localparam int LP = 4;
  always_comb begin
    y = LP;
    z = UP;
    w = PA;
  end
endmodule
