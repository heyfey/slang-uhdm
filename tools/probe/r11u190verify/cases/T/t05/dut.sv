// § classTpQualDefaultSpan180 § classTpDefaultTsAtUse180 § classTpFormalMovesTs180 (r11u190: a package-qualified default that is a PARAMETERIZED class with a named override, used and taken as a formal)
package other;
  class par_c #(int W = 4);
    bit [W-1:0] d;
  endclass
endpackage
package pkg;
  class holder #(type CB = other::par_c#(.W(8)));
    CB m;
    function void f(CB x);
      m = x;
    endfunction
  endclass
endpackage
module top;
  pkg::holder h;
endmodule
