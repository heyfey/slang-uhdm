// § caStructParamIfaceCloneReused289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; logic [11:0] w; } s_t;
  localparam s_t K = '{n: 4'h6, m: 8'b1100_0011, w: 12'h5A3};
endpackage
package p;
  typedef struct packed { logic [7:0] n; logic [3:0] k; } cfg_t;
endpackage
interface ifc #(parameter p::cfg_t C = '{n: 8'h5, k: 4'b1010}) ();
  logic [7:0] a;
  logic [7:0] b;
  assign a = C.n;
  assign b = C.n;
endinterface
module dut (output logic [7:0] o);
  ifc #(.C('{n: {4'h3, 4'h4}, k: 4'b0001})) u_i ();
  assign o = u_i.a ^ u_i.b;
endmodule
