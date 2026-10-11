// § ifSelShareConstBounds289v
package p;
  typedef struct packed { logic [7:0] n; } cfg_t;
endpackage
interface ifc #(parameter p::cfg_t C = '{n: 8'h5}, parameter int L = 4) ();
  logic [7:0] whole;
  logic [15:0] ps;
  assign whole = C.n;
  assign ps[L+7:L] = C.n;
endinterface
module dut (output logic [15:0] o);
  ifc u_i ();
  assign o = u_i.ps ^ {8'b0, u_i.whole};
endmodule
