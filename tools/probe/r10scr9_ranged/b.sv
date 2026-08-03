// r10scr9 purpose-built golden for § elabRangedRerender (see the NOTE above
// the `if (!rhs && topView)` block in src/ParamEmit.cpp).  One localparam per
// literal form, all ranged by a $unit-scope parameter.
//
// The pair is inc.svh's INCLUDE GUARD:
//   - as written, `localparam UW` materialises only in a.sv, so from b.sv it
//     is a CROSS-ROOT-FILE $unit reference -> Surelog cannot value the range
//     and every elab constant is re-rendered at width 1;
//   - delete the `ifndef/define/endif` and the declaration lands in both root
//     files -> the range resolves and the same constants come out at width 5.
// That one edit is the whole discriminator; everything else is identical.
//
// Run:
//   surelog -parse -elabuhdm -d uhdm -I. a.sv b.sv
//   /tmp/r10scr9_c slpp_all/surelog.uhdm        # tools/probe/r10scr9c.cpp
//   <slang-uhdm> a.sv b.sv --single-unit --elabuhdm -o ours.uhdm
`include "inc.svh"
module sub;
localparam [UW-1:0] P_D0  = 5'd0;
localparam [UW-1:0] P_B1  = 1'b1;
localparam [UW-1:0] P_SUM = 5'd2 + 5'd3;
localparam [UW-1:0] P_H1F = 8'h1f;
localparam [UW-1:0] P_INT = 7;
endmodule
