// § pkgStructMemberSysArgBind404
package p;
  parameter int n = 32768;
  parameter int m = 4;
  typedef struct packed {
    logic [$clog2(n)-1:0] a;
    logic [m-1:0] b;
  } s_t;
endpackage
module top; endmodule
