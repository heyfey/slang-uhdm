// § cloneRetNoMintBindsHome232
// a struct return: member assignments through the return name, an inline body
package p1;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  class c;
    function s_t f(int x);
      f.a = x[3:0];
      f.b = f.a[0];
    endfunction
    static function int h(int x);
      h = x;
      h++;
      h += 2;
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
