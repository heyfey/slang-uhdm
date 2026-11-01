// § pkgTdForeignSpecParams460 (specialization argument a package typedef of int)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
endpackage
package a;
  import u::*;
  typedef int myint;
  typedef S #(myint, bit) a_seqr;
endpackage
module top;
  import a::*;
  a_seqr h;
  initial h = new;
endmodule
