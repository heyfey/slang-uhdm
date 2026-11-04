// § fwWinnerSpecKind257 (default int also written explicitly beside a byte specialization)
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
class h1; aa_reg #(int) a; aa_reg #(byte) b; endclass
endpackage
module top; endmodule
