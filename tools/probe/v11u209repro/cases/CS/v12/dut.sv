// § classTdPkgEnumMemberShares209: a function returning a union of package enums, in a paren-less function
package p;
  typedef enum logic [1:0] { R0, R1, R2 } req_e;
  typedef enum logic [1:0] { C0, C1 } cmd_e;
  typedef union packed { req_e req; cmd_e cmd; } msg_u;
  typedef struct packed { msg_u m; logic v; } hdr_s;
  typedef msg_u msg2_u;
endpackage
module top(input logic [1:0] a, output p::msg_u o);
  function automatic p::msg_u h;
    input logic [1:0] z;
    p::msg_u t;
    t.req = p::req_e'(z);
    h = t;
  endfunction
  assign o = h(a);
endmodule
