// r10uvm104 arm 7 — token pastes OUTSIDE a stringification (identifier
// building, the `` ``T`` `` / `` ``_`` `` shapes in uvm_packer.svh and
// ovm_object_defines.svh).  Nothing here may move: Surelog's regex lives in
// the STRING listener.
`define FLD(a) fld_``a``_end
`define TWO(a,b) a``_``b
module out_top;
  wire `FLD(alpha);
  wire `TWO(left,right);
  initial begin
    if (1) $display("plain string, no backtick");
  end
endmodule
