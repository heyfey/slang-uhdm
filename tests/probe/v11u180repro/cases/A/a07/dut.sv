// § classTpQualDefaultSpan180 (verifier: a qualified parameterized default with blanks)
package other;
  class par_c #(int N = 1); endclass
endpackage
package pkg;
  class holder #(type CB = other :: par_c #( 8 ));
    CB m;
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
