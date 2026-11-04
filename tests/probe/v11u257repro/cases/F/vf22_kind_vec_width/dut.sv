// § fwWinnerSpecKind257 (a vector typedef whose width follows a value parameter, two specializations, default never written)
package p;
class aa_reg #(int W=4); typedef logic [W-1:0] this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class h1; aa_reg #(8) a; aa_reg #(2) b; endclass
endpackage
module top; endmodule
