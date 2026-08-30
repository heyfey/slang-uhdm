// v4_forms102 -- every OTHER bound face on a PACKAGE-owned array parameter,
// beside the law's own `N-1`: `N`, `N+1`, `N*2`, `$clog2`, `$bits`, a literal,
// a nested select, two parameters in one bound, and a parenthesised subtract.
package v4p102;
  parameter int N  = 4;
  parameter int M  = 2;
  typedef logic [7:0] w_t;
  parameter int SEL [0:3] = '{3,2,1,0};
  parameter int F_SUB   [0:N-1]           = '{default:0};
  parameter int F_BARE  [0:N]             = '{default:0};
  parameter int F_ADD   [0:N+1]           = '{default:0};
  parameter int F_MUL   [0:N*2]           = '{default:0};
  parameter int F_CLOG  [0:$clog2(N)]     = '{default:0};
  parameter int F_BITS  [0:$bits(w_t)-1]  = '{default:0};
  parameter int F_LIT   [0:3]             = '{default:0};
  parameter int F_NSEL  [0:SEL[0]]        = '{default:0};
  parameter int F_TWO   [0:N-M]           = '{default:0};
  parameter int F_PAREN [0:(N-1)]         = '{default:0};
  parameter int F_SIZE  [N]               = '{default:0};
endpackage

module v4sub102;
  import v4p102::*;
  int t = F_SUB[0]+F_BARE[0]+F_ADD[0]+F_MUL[0]+F_CLOG[0]+F_BITS[0]+F_LIT[0]
        + F_NSEL[0]+F_TWO[0]+F_PAREN[0]+F_SIZE[0];
endmodule

module v4_forms102;
  v4sub102 u_a();
endmodule
