// § caStructParamIfaceCloneReused289
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
  if (1) begin : g
    ifc u_i ();
    assign o = u_i.a ^ u_i.b;
  end
endmodule
