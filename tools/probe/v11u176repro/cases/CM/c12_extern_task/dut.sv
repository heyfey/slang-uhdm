// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class k;
    extern task t(input e_t x, output int y);
  endclass
  task k::t(input e_t x, output int y);
    y = int'(x);
  endtask
endpackage
module top;
  import p::*;
  k o; int r;
  initial begin o = new; o.t(B, r); end
endmodule
