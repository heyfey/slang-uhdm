// § pkgStructMemberSysArgBind404
package p;
  parameter int n = 32768;
  parameter m = 4;
  localparam int k = $clog2(n);
  typedef logic [$clog2(m)-1:0] t_t;
  typedef struct packed {
    logic [$clog2(n+1)-1:0] a;
    logic [$bits(n)-1:0] b;
    logic [$clog2(m):0] c;
  } s_t;
endpackage
module top; 
  parameter int q = 16;
  typedef struct packed { logic [$clog2(q)-1:0] a; } ms_t;
  ms_t v;
  logic [$clog2(q)-1:0] w;
endmodule
