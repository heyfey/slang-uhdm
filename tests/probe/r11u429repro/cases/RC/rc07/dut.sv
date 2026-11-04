// § unitClsCastPkgEnumTdTopListing429
package p;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
  typedef enum bit [RB-1:0] { C0 = 1, C1 = 2 } f_t;
  typedef enum int { D0, D1 } g_t;
endpackage
import p::*;
class C;
  function void f(int x);
    g_t v;
    v = g_t'(x);
  endfunction
endclass
module top;
  C c = new;
endmodule
