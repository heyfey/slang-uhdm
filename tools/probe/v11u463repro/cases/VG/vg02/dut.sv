// § firstListerNamesClassTd463 (the same specialization S#(int) typedef'd in b then a)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b;
  import u::*;
  typedef S #(int) b_si;
endpackage
package a;
  import u::*;
  typedef S #(int) a_si;
endpackage
module top;
endmodule
