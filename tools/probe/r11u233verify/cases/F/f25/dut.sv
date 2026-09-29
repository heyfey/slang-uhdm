// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a conditional with a condition holding the reference (C && p2::E1 ? a : b) and a pattern member ternary
package p1;
  typedef struct packed { logic [2:0] x; } s_t;
  localparam bit C = 1;
  localparam int Y = C && p2::E1 ? 3 : 4;
  localparam s_t S = '{x: p2::K > 2 ? p2::E1 : p2::E2};
  localparam int X = Y + int'(S);
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
