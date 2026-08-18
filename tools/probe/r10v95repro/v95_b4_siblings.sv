// r10v95 arm b4 — the SIBLING type queries over select-bearing arguments.
// The patch must not touch any of them.
module b4;
  bit [31:0] s32;
  byte       ar8 [6];
  byte       dq [];
  int        two [2][4];
  int        z [30];
  initial begin
    z[0]  = $size(ar8);
    z[1]  = $size(ar8[1]);
    z[2]  = $size(two, 2);
    z[3]  = $clog2($bits(s32[3]));
    z[4]  = $high(ar8);
    z[5]  = $high(two, 1);
    z[6]  = $low(ar8);
    z[7]  = $left(s32);
    z[8]  = $left(s32[7:0]);
    z[9]  = $right(s32);
    z[10] = $dimensions(two);
    z[11] = $dimensions(ar8[0]);
    z[12] = $unpacked_dimensions(two);
    z[13] = $increment(ar8);
    z[14] = $size(dq);
    z[15] = $bits(s32[3]);
    z[16] = $clog2(ar8[2]);
  end
endmodule
