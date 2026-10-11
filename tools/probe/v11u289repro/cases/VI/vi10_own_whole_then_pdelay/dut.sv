// § caDelayNameRefKeepsOperand289v
package p;
  typedef struct packed { logic [7:0] n; } cfg_t;
endpackage
interface ifc #(parameter p::cfg_t C = '{n: 8'h5}, parameter int D = 2) ();
  logic [7:0] a;
  logic [7:0] b;
  assign a = C.n;
  assign #D b = C.n;
endinterface
module dut (output logic [7:0] o);
  ifc u_i ();
  assign o = u_i.a ^ u_i.b;
endmodule
