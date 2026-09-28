// (r11u191 queue twin) a queue typedef of a class type parameter returned by a static function, bounded queue
package p;
  class utils #(type TYPE = int);
    typedef TYPE types_t[$:7];
    static function types_t find_all(int start);
      types_t t;
      return t;
    endfunction
  endclass
endpackage
module top;
  p::utils #(int) u;
endmodule
