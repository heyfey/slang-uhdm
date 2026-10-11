// § caStructParamIfaceCloneReused289
package p;
  typedef struct packed { logic [7:0] n; logic [3:0] k; } cfg_t;
endpackage
interface inner #(parameter p::cfg_t C = '{n: 8'h5, k: 4'b1010}) ();
  logic [7:0] a;
  logic [7:0] b;
  assign a = C.n;
  assign b = C.n;
endinterface
interface outer ();
  inner u_in ();
endinterface
module dut (output logic [7:0] o);
  outer u_o ();
  assign o = u_o.u_in.a ^ u_o.u_in.b;
endmodule
