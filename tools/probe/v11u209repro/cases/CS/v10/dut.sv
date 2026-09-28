// § classTdPkgEnumMemberShares209: a struct holding a union of package enums as a function formal and return
package p;
  typedef enum logic [1:0] { R0, R1, R2 } req_e;
  typedef enum logic [1:0] { C0, C1 } cmd_e;
  typedef union packed { req_e req; cmd_e cmd; } msg_u;
  typedef struct packed { msg_u m; logic v; } hdr_s;
  typedef msg_u msg2_u;
endpackage
module top(input p::hdr_s i, output p::hdr_s o, output logic [1:0] k);
  function automatic p::hdr_s g(input p::hdr_s x);
    p::hdr_s r;
    r = x;
    r.m.cmd = p::C1;
    return r;
  endfunction
  assign o = g(i);
  assign k = o.m.req;
endmodule
