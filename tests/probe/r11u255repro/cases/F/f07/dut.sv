// § fwWinnerListedObject255 (a non-generic first-key class: the listing is the only object, nothing moves)
package p;
virtual class vd; endclass
class aa_reg; typedef aa_reg this_type; endclass
class tif #(type T=int, type P=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
class a0user;
  typedef aa_reg type_id;
endclass
endpackage
module top; endmodule
