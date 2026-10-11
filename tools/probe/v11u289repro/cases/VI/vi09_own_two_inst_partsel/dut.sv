// § caIfaceSelLhsTakesSharedRhs289
package p;
  typedef struct packed { logic [7:0] n; logic [3:0] k; } cfg_t;
endpackage
interface ifc #(parameter p::cfg_t C = '{n: 8'h5, k: 4'b1010}) ();
  logic [3:0] wk;
  logic [7:0] ps;
  assign wk = C.k;
  assign ps[5:2] = C.k;
endinterface
module dut (output logic [7:0] o, output logic [7:0] o2);
  ifc u_i ();
  ifc u_j ();
  assign o = u_i.ps ^ {4'b0, u_i.wk};
  assign o2 = u_j.ps ^ {4'b0, u_j.wk};
endmodule
