// § fwWinnerSpecTieBreak257 (two specializations whose type arguments are same-named struct typedefs of two packages)
package q; typedef struct packed { logic a; } s_t; endpackage
package r; typedef struct packed { logic [1:0] a; } s_t; endpackage
package p;
class aa_reg #(type T=int); typedef aa_reg #(T) this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class h1; aa_reg #(q::s_t) a; aa_reg #(r::s_t) b; endclass
endpackage
module top; endmodule
