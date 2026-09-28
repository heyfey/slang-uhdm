// § classTdPkgEnumMemberShares209: a package union of package enums as a module port and a function formal
package p;
  typedef enum logic [1:0] { R0, R1, R2 } req_e;
  typedef enum logic [1:0] { C0, C1 } cmd_e;
  typedef union packed { req_e req; cmd_e cmd; } msg_u;
  typedef struct packed { msg_u m; logic v; } hdr_s;
  typedef msg_u msg2_u;
endpackage
module top(input p::msg_u i, output logic [1:0] o);
  function automatic logic [1:0] f(p::msg_u x);
    return (x.req == p::R1) ? 2'd1 : x.cmd;
  endfunction
  assign o = f(i);
endmodule
