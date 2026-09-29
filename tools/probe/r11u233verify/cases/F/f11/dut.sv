// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a package referenced both forward (by p0) and backward (by p3)
package p1;
  localparam int X = 1;
endpackage
package p0;
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S0 = '{x: p2::E2};
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
package p3;
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S3 = '{x: p2::E2};
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
