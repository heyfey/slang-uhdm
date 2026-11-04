// § classTpChainRootShares180 § classTpFormalMovesTs180 § classTpDefaultTsAtUse180 (r11u190: a chain of three type parameters; uses on the first two, the only formal on the last)
package pkg;
  class base_c;
  endclass
  class holder #(type A = base_c, type B = A, type C = B);
    A a1;
    B b1;
    function void put(C c);
      a1 = c;
    endfunction
  endclass
endpackage
module top;
  pkg::holder h;
endmodule
