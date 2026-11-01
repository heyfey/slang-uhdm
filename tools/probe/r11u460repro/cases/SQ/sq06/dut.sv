// § clsNestedSpecCloneHomeInst460 (control: a $unit class's listing copies keep their instance)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    typedef S #(REQ, RSP) this_type;
    REQ r;
  endclass
  typedef S #(item, item) dflt_t;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
package e;
  import u::*;
  import a::*;
  class env;
    a_seqr h;
  endclass
endpackage
import u::*;
import e::*;
import a::*;
class test;
  env v;
endclass
module top;
  initial begin test t; t = new; end
endmodule
