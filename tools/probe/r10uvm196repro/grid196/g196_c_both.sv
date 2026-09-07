// FILE-SCOPE and MODULE-BODY together — the arm that tests rather than agrees.
import quarryPkg::*;
module cBoth;
  import quarryPkg::*;
  int r;
  initial r = quarryTake(4);
endmodule
module cFileOnly;
  int r;
  initial r = quarryTake(5);
endmodule
