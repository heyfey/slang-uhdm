// § firstListerNamesClassTd463 (next face: the module listing of a $unit-imported package's transitive class typedefs)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
endpackage
package b;
  import u::*;
  class b_item extends item; endclass
  typedef S #(b_item) B_seqr;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) A_seqr;
endpackage
package abc;
  import a::*;
  import b::*;
endpackage
package e;
  import abc::*;
  import a::*;
  class env;
    A_seqr h;
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
