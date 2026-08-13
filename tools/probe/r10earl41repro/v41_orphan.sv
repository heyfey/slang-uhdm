// r10earl41 F4 — THE ORPHAN PROBE, carried forward from
// r10earl40repro/v40_orphan.sv (identical shape, renamed package/module so the
// two can be run side by side).
//
// `r41::A[g][DW-1 -: 4]` is a package-qualified TWO-selector select whose
// second selector is an INDEXED range.  r10earl40's delegation fires (two
// selectors, qualified base), the multi-selector builder mints the var_select,
// its expr_vec and the first index, THEN meets the `-:` it cannot build and
// returns nullptr.  The delegation correctly falls back to the old ref_obj —
// but the minted objects are already in the serializer's arena and are WRITTEN
// OUT as unreachable garbage.
//
// THE MEASUREMENT: the uhdm-dump output is BYTE-IDENTICAL before and after the
// fix (the garbage is unreachable, so no walk ever prints it) while the FILE
// SIZE drops back to what it is without the abstention.  Bytes are the only
// instrument that can see this, which is why it is a separate probe.
package r41;
  parameter logic [3:0][7:0] A = {8'h1, 8'h2, 8'h3, 8'h4};
endpackage
module v41_orphan #(parameter int DW = 8) (output logic [3:0] o);
  for (genvar g = 0; g < 1; g++) begin : gb
    logic [3:0] c_ips;
    assign c_ips = r41::A[g][DW-1 -: 4];
  end
  assign o = gb[0].c_ips;
endmodule
