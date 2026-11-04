// § fwWinnerSpecKind257 (default int, two specializations byte and shortint)
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
class u1; aa_reg #(byte) h1; aa_reg #(shortint) h2; endclass
endpackage
module top; endmodule
