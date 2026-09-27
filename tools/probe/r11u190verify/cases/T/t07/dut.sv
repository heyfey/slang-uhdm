// § classTpDefaultTsAtUse180 (r11u190: a class-local typedef of the type parameter beside direct uses; associative and dynamic array elements)
package pkg;
  class base_c;
  endclass
  class holder #(type CB = base_c);
    typedef CB cb_t;
    cb_t a;
    CB b;
    CB am[string];
    CB da[];
  endclass
endpackage
module top;
  pkg::holder h;
endmodule
