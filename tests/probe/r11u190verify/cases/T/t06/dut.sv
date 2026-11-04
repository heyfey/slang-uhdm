// § classTpDefaultTsAtUse180 § classTpFormalMovesTs180 (r11u190: a POSITIONAL type override of two type parameters, the second not a class)
package pkg;
  class base_c;
  endclass
  class ext_c;
  endclass
  class holder #(type CB = base_c, type D = int);
    CB m;
    D n;
    function void f(CB x, D y);
      m = x;
      n = y;
    endfunction
  endclass
endpackage
module top;
  pkg::holder #(pkg::ext_c, logic [3:0]) h1;
  pkg::holder h2;
endmodule
