// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a macro carrying the reference into a pattern member, part-select bounds and a replication count
package p1;
  `define R p2::E2
  typedef struct packed { logic [2:0] x; logic [2:0] y; logic [1:0][7:0] z; } s_t;
  localparam s_t S = '{x: `R, y: p2::W[`R:0], z: '{`R{8'h1}}};
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
