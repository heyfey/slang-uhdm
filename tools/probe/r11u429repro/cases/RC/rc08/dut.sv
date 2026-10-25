// § unitClsCastPkgEnumTdTopListing429
package p;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
  typedef enum bit [RB-1:0] { C0 = 1, C1 = 2 } f_t;
  typedef enum int { D0, D1 } g_t;
endpackage
package q;
  import p::*;
  class C;
    function void f(int x);
      e_t v;
      v = e_t'(x & 3);
    endfunction
  endclass
endpackage
module top;
  q::C c = new;
endmodule
