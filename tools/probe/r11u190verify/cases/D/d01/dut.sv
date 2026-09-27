// (r11u190 determinism: the UVM constant coin, uvm_misc.svh 642 `typedef TYPE types_t[$]` returned by `find_all`) a queue typedef of a class type parameter returned by a static function
package p;
  class utils #(type TYPE = int);
    typedef TYPE types_t[$];
    static function types_t find_all(int start);
      types_t t;
      return t;
    endfunction
  endclass
endpackage
module top;
  p::utils #(int) u;
endmodule
