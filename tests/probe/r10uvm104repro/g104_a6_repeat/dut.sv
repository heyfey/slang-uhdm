// r10uvm104 arm 6 — REPEATED separators.  The real ovm-2.1.2 and uvm-1.1d
// version strings put the same character between two different paste pairs
// ("OVM-2.1.2", "UVM-1.1d"), so a single-anchor alignment is ambiguous; the
// model resolves it by requiring the left-to-right and right-to-left walks to
// agree.  Copied here with the real macro shapes and with an extra
// three-separator case.
`define VN OVM
`define VMA 2
`define VMI 1
`define VFX 2
`define V_OVM `"`VN``-```VMA``.```VMI``.```VFX`"
`define UN UVM
`define UMA 1
`define UMI 1
`define UFX d
`define V_UVM11 `"`UN``-```UMA``.```UMI`UFX`"
`define V_TRIPLE `"`VN``-```VMA``-```VMI``-```VFX`"
`define V_SAMECH `"`VN``.```VMA``.```VMI``.```VFX`"
package rep_pk;
  parameter string r_ovm    = `V_OVM;
  parameter string r_uvm11  = `V_UVM11;
  parameter string r_triple = `V_TRIPLE;
  parameter string r_samech = `V_SAMECH;
endpackage
module rep_top; endmodule
