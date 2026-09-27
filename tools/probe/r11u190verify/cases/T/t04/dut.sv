// § classTpFormalMovesTs180 § classTpDefaultTsAtUse180 (r11u190: the type parameter as a formal of a STATIC method and as a static property and a static return)
package pkg;
  class base_c;
  endclass
  class holder #(type CB = base_c);
    static CB inst;
    static function void set(CB x);
      inst = x;
    endfunction
    static function CB get();
      return inst;
    endfunction
  endclass
endpackage
module top;
  pkg::holder h;
endmodule
