// § caIfaceSelLhsTakesSharedRhs289
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] whole;
  logic [31:0] bitsel;
  assign bitsel[0] = C.n;
  assign whole     = C.n;
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.whole ^ u_i.bitsel;
endmodule
