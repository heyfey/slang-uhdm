// r11u65 n6 — CONTAINER KINDS OUR EXPORTER REJECTS TODAY.  Recorded as a
// measured FENCE, not as a law cell: `slang-uhdm` exits non-zero with
// "typedef target: QueueType / DynamicArrayType / AssociativeArrayType", so no
// net of these shapes exists in any database of ours and none can move.
// Golden's own answer is listed for the record.
module dut #(parameter int unsigned N = 2) (output logic [N-1:0] o);
  typedef logic [N-1:0] qq_t [$];       // queue
  typedef logic [N-1:0] dd_t [];        // dynamic
  typedef logic [N-1:0] as_t [string];  // associative
  qq_t qq;  dd_t dd;  as_t as;
  assign o = qq[0] | dd[0] | as["k"];
endmodule
