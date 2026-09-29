// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a system call with two forward arguments inside a pattern member
package p1;
  typedef struct packed { logic [7:0] x; } s_t;
  localparam s_t S = '{x: $clog2(p2::K) + $bits(p2::W)};
  localparam int X = int'(S);
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
