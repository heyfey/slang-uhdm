// § fwWinnerListedObject255 (the winner declared in an included header)
`include "reg.svh"
package p;
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
class user; typedef q::aa_reg #(user, "user") type_id; endclass
endpackage
module top; endmodule
