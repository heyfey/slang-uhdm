// § fwWinnerSpecKind257 (the kind-changing specialization made in a module)
package p;
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
endpackage
module top; p::aa_reg #(byte) h; p::sock #(int) s; endmodule
