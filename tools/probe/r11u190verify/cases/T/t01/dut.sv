// § classTpDefaultTsAtUse180 § classTpFormalMovesTs180 (r11u190: the default is a package TYPEDEF naming a class; uses as a property, a local and a return)
package pkg;
  class base_c;
    int k;
  endclass
  typedef base_c base_t;
  class holder #(type CB = base_t);
    CB m;
    function CB get();
      CB loc;
      loc = m;
      return loc;
    endfunction
  endclass
endpackage
module top;
  pkg::holder h;
endmodule
