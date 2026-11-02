// § firstListerNamesClassTd463
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
endpackage
package b;
  import u::*;
  class b_item extends item; endclass
  typedef S #(b_item) b_seqr;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
package e;
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
  a_seqr q;
endclass
module top;
  initial begin test t; t = new; end
endmodule
