// r10earl106 h1_head106 — THE HEAD SHAPE, reduced from Earlgrey_0_1
// padctrl.sv:36-45.  A gen-IF scope's cont_assign whose Rhs is a WIDTH CAST
// of a sized literal, assigned to a MODULE-BODY vector.  MEASUREMENT ONLY.
package pk106;
  parameter int unsigned AttrDw = 8;
  typedef enum logic [1:0] { ImplGeneric = 0, ImplXilinx = 1 } impl_e;
endpackage

module h1_head106 import pk106::*; #(
  parameter pk106::impl_e Impl = pk106::ImplGeneric
) (
  output logic [AttrDw-1:0] o_mask,
  output logic [AttrDw-1:0] o_mask2
);
  logic [AttrDw-1:0] warl_mask;
  logic [AttrDw-1:0] warl_mask2;
  if (Impl == pk106::ImplGeneric) begin : gen_generic
    assign warl_mask = AttrDw'(6'h3F);
  end else begin : gen_others
    assign warl_mask = AttrDw'(6'h3F);
  end
  // the module-body twin of the same shape, for the home axis
  assign warl_mask2 = AttrDw'(6'h3F);
  assign o_mask = warl_mask;
  assign o_mask2 = warl_mask2;
endmodule
