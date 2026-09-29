// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — the later package in an included file (another file: the law declines)
package p1;
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S = '{x: p2::E1};
  localparam int X = int'(S);
endpackage
`include "p2.svh"
module dut (output int o);
  assign o = p1::X;
endmodule
