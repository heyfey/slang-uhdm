package pk37;
  parameter int P37 = 5;
  class Base37;
    int b;
  endclass
endpackage
module top;
  import pk37::*;
  class Der37 extends Base37;
    int d;
  endclass
  Der37 c;
endmodule
