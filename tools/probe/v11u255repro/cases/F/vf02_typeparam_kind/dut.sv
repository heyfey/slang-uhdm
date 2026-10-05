// § fwWinnerListedObject255 (the winner's typedef a type parameter: the specialisation's kind differs from the listing's)
package p;
virtual class vd; endclass
class aa_reg #(type T=int); typedef T this_type; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
class user;
  aa_reg #(byte) h1;
endclass
endpackage
module top; endmodule
