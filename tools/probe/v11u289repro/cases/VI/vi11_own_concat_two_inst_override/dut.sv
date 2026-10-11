// § caStructParamIfaceCloneReused289
package p;
  typedef struct packed { logic [7:0] n; } cfg_t;
endpackage
interface ifc #(parameter p::cfg_t C = '{n: {4'h1, 4'h2}}) ();
  logic [7:0] a;
  logic [7:0] b;
  assign a = C.n;
  assign b = C.n;
endinterface
module dut (output logic [7:0] o);
  ifc u_i ();
  ifc #(.C('{n: 8'h7})) u_j ();
  assign o = u_i.a ^ u_i.b ^ u_j.a ^ u_j.b;
endmodule
