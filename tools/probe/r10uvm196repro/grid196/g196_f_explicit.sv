// EXPLICIT file-scope imports, and the ORDER of two import items.
import quarryPkg::QUARRY_NAME;
import quarryPkg::QUARRY_DEPTH;
module fExp;
  parameter int F_OWN = 9;
  int r;
  initial r = QUARRY_DEPTH + F_OWN;
endmodule
