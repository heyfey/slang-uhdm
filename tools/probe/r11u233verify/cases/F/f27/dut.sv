// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a packed dimension of a $bits type argument inside a pattern member
package p1;
  typedef struct packed { logic [7:0] x; } s_t;
  localparam s_t S = '{x: $bits(logic [p2::K-1:0])};
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
