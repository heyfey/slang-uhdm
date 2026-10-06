// § pkgQualOvrPatInitSpan268
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage
module leaf #(parameter p::cfg_t C = p::A) (output logic [31:0] o);
  assign o = C.n;
endmodule
interface ifc #(parameter p::cfg_t C = p::A); logic [31:0] v; assign v = C.n; endinterface
module top import p::*; (output logic [31:0] o);
  if (1) begin : g
    ifc #(.C(B)) i ();
    assign o = i.v;
  end
endmodule
