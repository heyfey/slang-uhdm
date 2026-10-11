// § caIfaceSelLhsTakesSharedRhs289
package p;
  typedef struct packed { logic [7:0] n; } cfg_t;
endpackage
interface ifc #(parameter p::cfg_t C = '{n: 8'h5}) ();
  logic [7:0] whole;
  logic [7:0] arr [0:1];
  assign whole = C.n;
  assign arr[1] = C.n;
endinterface
module dut (output logic [7:0] o);
  ifc u_i ();
  assign o = u_i.whole ^ u_i.arr[1];
endmodule
