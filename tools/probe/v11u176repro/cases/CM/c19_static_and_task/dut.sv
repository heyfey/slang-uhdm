// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class k;
    static function int s(e_t x);
      return int'(x);
    endfunction
    virtual task t(input e_t y);
    endtask
  endclass
endpackage
module top;
  import p::*;
  int r;
  initial r = k::s(B);
endmodule
