// t4: PACKAGE type params; a module type-param default whose bound reads a
// package parameter WITH its qualifier (QT); and the same read written BARE
// under a wildcard import (BT) -- the § crossPkgRangeBoundFold squares.
package pk;
  localparam int PW = 6;
  parameter  type PPT = logic [PW-1:0];
  localparam type PLT = logic [PW-1:0];
endpackage
module dut #(
    parameter  type QT = logic [pk::PW-1:0],
    parameter  type CT = logic [pk::PW:0]
) (input QT q, input CT c, output logic o);
  import pk::*;
  localparam type BT = logic [PW-1:0];
  BT b;
  assign o = ^{q,c,b};
endmodule
