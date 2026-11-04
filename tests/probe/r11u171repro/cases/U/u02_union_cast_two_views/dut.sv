// § castUnionCloneFile171
package p;
  typedef union packed {
    logic [7:0] w;
    logic [1:0][3:0] n;
  } u_t;
endpackage
module sub import p::*; (input logic [7:0] i, output logic [3:0] o);
  u_t d;
  assign d = u_t'(i);
  assign o = d.n[1];
endmodule
module dut (input logic [7:0] i, output logic [3:0] o1, o2);
  sub a(i, o1);
  sub b(~i, o2);
endmodule
