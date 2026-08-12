// VERIFIER CELL g02 - POSITION outside a procedural block: a CONTINUOUS
// ASSIGNMENT and a port connection inside an uninstantiated generate block.
module top59g02;
  int i;
  if (0) begin : gblk
    wire [3:0] w;
    assign w = nosuchpkg59::wfn(1);
  end
  initial begin
    i = 1;
  end
endmodule
