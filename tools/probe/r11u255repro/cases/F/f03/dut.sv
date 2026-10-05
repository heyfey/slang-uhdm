// § fwWinnerListedObject255 (the winner a derived specialisation: identity moves, the walk lists both)
package p;
virtual class vd; endclass
virtual class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
class cc_reg #(type T=int, string N="x") extends aa_reg #(T,N); endclass
class tif #(type T=int, type P=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
class user;
  cc_reg #(byte, "y") h1;
endclass
endpackage
module top; endmodule
