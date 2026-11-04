// § classTpDefaultTsAtUse180 (verifier: the default is a class of another package reached by import)
package other;
  class base_c; endclass
endpackage
package pkg;
  import other::*;
  class holder #(type CB=base_c);
    CB m;
    CB arr[4];
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
