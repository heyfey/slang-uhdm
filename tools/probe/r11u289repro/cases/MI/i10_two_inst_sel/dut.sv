// § caIfaceSelLhsTakesSharedRhs289
package p;
  typedef struct packed { logic [7:0] n; } cfg_t;
endpackage
interface ifc #(parameter p::cfg_t C = '{n: 8'h5}) ();
  logic [7:0] whole;
  logic [15:0] ps;
  assign whole     = C.n;
  assign ps[11:4] = C.n;
endinterface
module dut (output logic [15:0] o);
  ifc u_i ();
  ifc #(.C('{n: 8'h7})) u_j ();
  assign o = u_i.ps ^ u_j.ps ^ {u_i.whole, u_j.whole};
endmodule
