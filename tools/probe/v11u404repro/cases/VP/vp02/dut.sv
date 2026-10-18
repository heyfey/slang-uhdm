// § pkgStructMemberSysArgBind404
package q; parameter int m = 16; endpackage
package p;
  import q::*;
  parameter int n = 8;
  typedef struct packed {
    logic [$clog2(m)-1:0] a;
    logic [$clog2(n+1)-1:0] b;
    logic [$clog2(q::m)-1:0] c;
  } s_t;
endpackage
module top; p::s_t v; endmodule
