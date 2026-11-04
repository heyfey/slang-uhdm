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
  extern function void f(int x);
endclass
function void C::f(int x);
  e_t v;
  v = e_t'(x & 3);
endfunction
module top;
  C c = new;
endmodule
