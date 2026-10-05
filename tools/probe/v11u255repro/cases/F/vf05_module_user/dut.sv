// § fwWinnerListedObject255 (the socket specialised in a module and the formal used by a task too)
package p;
virtual class vd; endclass
virtual class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  task run(input this_type a, output this_type b); b = a; endtask
endclass
class user; typedef aa_reg #(user, "user") type_id; endclass
endpackage
module top;
  import p::*;
  sock #(byte) s;
  initial s = new;
endmodule
