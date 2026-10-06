// § fwWinnerSpecKind257 (default a packed struct, specialization a logic vector)
package p;
typedef struct packed { logic [3:0] a; } s_t;
class aa_reg #(type T=s_t); typedef T this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class h1; aa_reg #(logic [3:0]) a; aa_reg #(bit [1:0]) b; endclass
endpackage
module top; endmodule
