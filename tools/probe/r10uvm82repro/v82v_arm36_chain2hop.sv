package pa36;
  parameter int P36 = 1;
endpackage
package pb36;
  import pa36::*;
endpackage
module top;
  import pb36::*;
  class C36;
    int x;
  endclass
  C36 c;
endmodule
