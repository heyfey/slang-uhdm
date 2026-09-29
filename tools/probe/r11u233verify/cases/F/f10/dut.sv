// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — three packages in a chain: p1 reads p2 forward, p2 reads p3 forward
package p1;
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S = '{x: p2::E1};
  localparam int X = int'(S);
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0] z; } t_t;
  localparam t_t T = '{z: p3::M};
endpackage
package p3;
  localparam logic [3:0] M = 4'd9;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
