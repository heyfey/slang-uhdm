// § classTdPkgEnumMemberShares209: a typedef of a union typedef holding package enums
package p;
  typedef enum logic [1:0] { R0, R1, R2 } req_e;
  typedef enum logic [1:0] { C0, C1 } cmd_e;
  typedef union packed { req_e req; cmd_e cmd; } msg_u;
  typedef struct packed { msg_u m; logic v; } hdr_s;
  typedef msg_u msg2_u;
endpackage
module top(input p::msg2_u i, output logic [1:0] o);
  p::msg2_u r;
  assign r = i;
  assign o = r.req;
endmodule
