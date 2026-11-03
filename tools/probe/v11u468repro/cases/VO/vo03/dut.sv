// § oobClassTdImporterClass468
module m1;
  import p::*;
  class u1; typedef u1 this_type; endclass
  u1 h;
endmodule
module m2;
  import p::*;
  class u1; typedef u1 this_type; int k; endclass
  u1 h;
endmodule
module top; m1 a(); m2 b(); endmodule
