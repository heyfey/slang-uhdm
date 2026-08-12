// VERIFIER CELL h01 - a `::` scope whose FIRST segment is a KEYWORD scope
// ($unit), inside an uninstantiated block.  scopedSegId12 handles only
// Identifier/Class/IdentifierSelect names, so the gate should NOT fire.
module top59h01;
  int i;
  if (0) begin : gblk
    int j;
    initial begin
      j = $unit::nosuchfn(1);
    end
  end
  initial begin
    i = 1;
  end
endmodule
