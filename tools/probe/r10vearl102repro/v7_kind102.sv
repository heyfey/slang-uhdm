// v7_kind102 -- DECLARATION KINDS on a package-owned array whose bound is the
// law's `<param> - <literal>`: parameter / localparam / typed / aggregate and
// scalar defaults / a replicated pattern / an unsized-literal pattern.
package v7p102;
  parameter int N = 3;
  typedef logic [7:0] byte_t;
  parameter int         K_PAR   [0:N-1] = '{1,2,3};
  localparam int        K_LOC   [0:N-1] = '{1,2,3};
  parameter byte_t      K_TYPED [0:N-1] = '{default:8'h5};
  parameter int         K_DEF   [0:N-1] = '{default:0};
  parameter int         K_REP   [0:N-1] = '{N{7}};
  parameter logic [3:0] K_UNS   [0:N-1] = '{'1,'0,'1};
  parameter bit         K_SCAL  [0:N-1] = '{1'b1,1'b0,1'b1};
endpackage

module v7sub102;
  import v7p102::*;
  int t = K_PAR[0] + K_LOC[0] + int'(K_TYPED[0]) + K_DEF[0] + K_REP[0]
        + int'(K_UNS[0]) + int'(K_SCAL[0]);
endmodule

module v7_kind102;
  v7sub102 u_a();
endmodule
