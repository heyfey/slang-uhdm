// v2_dims102 -- 2 and 3 unpacked dimensions, LEFT / RIGHT / BOTH bounds in the
// subtract form, on a PACKAGE-owned array parameter and its module twin.
package v2p102;
  parameter int A = 3;
  parameter int B = 2;
  parameter int P2 [0:A-1][0:B-1]            = '{'{1,2},'{3,4},'{5,6}};
  parameter int P3 [0:A-1][0:B-1][0:A-1]     = '{default:0};
  parameter int PL [A-1:0]                   = '{1,2,3};   // subtract on the LEFT
  parameter int PB [A-1:B-1]                 = '{1,2};     // subtract on BOTH
  parameter int PMIX [0:A-1][B-1:0]          = '{default:0};
endpackage

module v2sub102;
  import v2p102::*;
  localparam int MA = 3;
  localparam int MB = 2;
  localparam int M2 [0:MA-1][0:MB-1] = '{'{1,2},'{3,4},'{5,6}};
  localparam int ML [MA-1:0]         = '{1,2,3};
  localparam int MB2 [MA-1:MB-1]     = '{1,2};
  int t = P2[0][0] + P3[0][0][0] + PL[0] + PB[1] + PMIX[0][0] + M2[0][0] + ML[0] + MB2[1];
endmodule

module v2_dims102;
  v2sub102 u_a();
endmodule
