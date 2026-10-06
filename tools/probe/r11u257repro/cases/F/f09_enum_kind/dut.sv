// § fwWinnerSpecKind257 (default int, specialization an enum)
package p;
typedef enum logic [1:0] {A, B} e_t;
class aa_reg #(type T=int); typedef T this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class u1; aa_reg #(e_t) h1; endclass
endpackage
module top; endmodule
