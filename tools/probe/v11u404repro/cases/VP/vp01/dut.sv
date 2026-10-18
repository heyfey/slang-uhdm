// § pkgStructMemberSysArgBind404
package p;
  localparam int n = 64;
  parameter int k = 3;
  typedef struct packed {
    logic [$clog2(n)-1:0] a;
    logic [$bits(k)-1:0] b;
    struct packed { logic [$clog2(k):0] c; } in;
  } s_t;
  typedef union packed { logic [$clog2(n)-1:0] u1; logic [5:0] u2; } u_t;
  typedef logic [$clog2(n)-1:0] t_t;
endpackage
module top; p::s_t v; p::u_t w; p::t_t x; endmodule
