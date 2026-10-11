// § caIfaceSelLhsTakesSharedRhs289
package p;
  typedef struct packed { logic [7:0] n; logic [3:0] k; } cfg_t;
endpackage
interface ifc #(parameter p::cfg_t C = '{n: 8'h5, k: 4'b1010}) ();
  logic [7:0] a;
  logic [3:0] kk;
  logic [15:0] s;
  assign a = C.n;
  assign kk = C.k;
  assign s[7:0] = C.n;
  assign s[11:8] = C.k;
  assign s[12] = C.k;
endinterface
module dut (output logic [15:0] o);
  ifc u_i ();
  assign o = u_i.s ^ {u_i.kk, u_i.a};
endmodule
