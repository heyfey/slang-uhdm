// § classTpDefaultTsAtUse180 § classTpFormalMovesTs180 (r11u190: a class nested inside the parameterized class uses the outer type parameter; an out-of-body method definition)
package pkg;
  class base_c;
  endclass
  class holder #(type CB = base_c);
    CB m;
    class inner;
      CB z;
    endclass
    extern function void f(CB x);
  endclass
  function void holder::f(CB x);
    CB t;
    t = x;
    m = t;
  endfunction
endpackage
module top;
  pkg::holder h;
endmodule
