// § classTpQualDefaultSpan180
package other;
  class par_c #(type T=int); endclass
endpackage
package pkg;
  class holder #(type CB=other::par_c#(int));
    CB m;
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
