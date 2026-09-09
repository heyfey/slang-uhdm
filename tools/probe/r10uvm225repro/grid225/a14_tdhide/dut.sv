// r10uvm225 arm a14_tdhide — a typedef that HIDES the unpacked dimension.
// Surelog's gate is the WRITTEN dimension (`orig_net->getUnpackedDimension()`,
// UhdmWriter.cpp:905), so a declaration with no bracket of its own should get
// NO array_net however unpacked its canonical type is.  (A typedef whose
// target is an ASSOCIATIVE or DYNAMIC array is a slang-uhdm reject —
// r10v224's R-D — so only the FIXED form can be asked.)
typedef logic [7:0] tvt225_t;

interface if225_td();
  // Declared IN the interface: a $unit `typedef t a [1:0]` is a slang-uhdm
  // reject ("typedef target: FixedSizeUnpackedArrayType") and an arm whose
  // compile fails teaches error recovery, not golden.
  typedef tvt225_t arr225_t [1:0];
  typedef tvt225_t arr2225_t [3];
  arr225_t   h_hidden225;          // no written dimension
  arr2225_t  h_hidden2225;         // no written dimension
  arr225_t   h_both225 [2];        // ONE written dimension over a hidden one
  tvt225_t   h_plain225 [1:0];     // the control
endinterface

module top225_td(); endmodule
