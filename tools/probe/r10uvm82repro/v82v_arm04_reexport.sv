package pa4;
  parameter int PA4 = 1;
endpackage
package pb4;
  import pa4::*;
  export pa4::*;
  parameter int PB4 = 2;
endpackage
module top;
  import pb4::*;
  class C;
    int x;
  endclass
  C c;
endmodule
