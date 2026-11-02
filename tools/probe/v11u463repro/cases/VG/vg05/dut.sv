// § firstListerNamesClassTd463 (generic class in package a itself, typedef in a and in later b (control))
package a;
  class item; endclass
  class S #(type REQ = item); REQ r; endclass
  class a_item extends item; endclass
  typedef S #(a_item) z_seqr;
endpackage
package b;
  import a::*;
  class b_item extends item; endclass
  typedef S #(b_item) b_seqr;
endpackage
module top;
endmodule
