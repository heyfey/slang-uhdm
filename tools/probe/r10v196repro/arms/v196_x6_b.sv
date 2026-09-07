// v196 arm X6 file B — no import at all; it only INSTANTIATES the module
// defined in file A.  Neither this module nor the instance may take copies
// (the buffer compared is the DEFINITION's).
module xSixTop(input int a, output int b);
  xSixLeaf u0(a, b);
endmodule
