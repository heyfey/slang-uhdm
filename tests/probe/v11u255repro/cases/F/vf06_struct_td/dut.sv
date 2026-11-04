// § fwWinnerListedObject255 (the winner's typedef a packed struct over a type parameter)
package p;
virtual class vd; endclass
class aa_reg #(type T=logic); typedef struct packed { T a; logic b; } this_type; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
class user; aa_reg #(logic [3:0]) h; endclass
endpackage
module top; endmodule
