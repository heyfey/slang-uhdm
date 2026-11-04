// § castUnionCloneFile171
package p;
  typedef struct packed {logic [3:0] a; logic [3:0] b;} s_t;
  typedef union packed {
    s_t s;
    logic [7:0] w;
  } u_t;
endpackage
module dut import p::*; (input logic [7:0] i, output logic [3:0] o);
  u_t d;
  assign d = u_t'(i);
  assign o = d.s.a;
endmodule
