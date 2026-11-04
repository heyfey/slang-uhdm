// § classTpQualDefaultSpan180
package other;
  class base_c; endclass
endpackage
package pkg;
  class holder #(type CB=other::base_c);
    CB m;
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
