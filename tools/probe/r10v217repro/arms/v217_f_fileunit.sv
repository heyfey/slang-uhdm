// v217 arm F — FILE-UNIT scope import of a package that itself imports (the
// x2 copy rule crossed with the transitive hop), and TWO ROADS TO ONE PACKAGE
// from a single home package (pu2 imports the chain pu1->pu0 AND pu0 direct).
// (A package importing ITSELF is rejected by slang, so that shape is not an
// arm: `error: package cannot import itself`.)
package pu0;
  int u0_v;
  string u0_s;
endpackage

package pu1;
  import pu0::*;
  int u1_v;
endpackage

package pu2;
  import pu1::*;
  import pu0::*;
  int u2_v;
endpackage

import pu1::*;

module vu_fileonly;
  logic vu_fileonly_clk;
endmodule

module vu_both;
  import pu1::*;
  logic vu_both_clk;
endmodule

module vu_tworoads;
  import pu2::*;
  logic vu_tworoads_clk;
endmodule
