// § classTpDefaultTsAtUse180
package pkg;
  class base_c; endclass
  class holder #(type A=base_c, type B=base_c);
    A a;
    B b;
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
