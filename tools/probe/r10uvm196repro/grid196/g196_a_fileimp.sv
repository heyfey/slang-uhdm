// FILE-SCOPE wildcard import.  Two modules in the SAME file: both must take the
// same materialization, and a module in ANOTHER file must take none.
import quarryPkg::*;
module aFileOne;
  int r;
  initial r = quarryTake(1);
endmodule
module aFileTwo;
  parameter int A_OWN = 2;      // an own parameter: the import copies LEAD it
  int r;
  initial r = quarryTake(2);
endmodule
