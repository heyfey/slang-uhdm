// § fwWinnerListedObject255 (the winner's typedef a vector sized by a value parameter, non-default specialisation first)
package p;
virtual class vd; endclass
class aa_reg #(int W=8); typedef logic [W-1:0] this_type; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
class user;
  aa_reg #(4) h1;
endclass
endpackage
module top; endmodule
