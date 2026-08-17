package pt6;
  parameter type T6 = int;
  parameter int PZ6 = 3;
endpackage
module top;
  import pt6::*;
  class C;
    int x;
  endclass
  C c;
endmodule
