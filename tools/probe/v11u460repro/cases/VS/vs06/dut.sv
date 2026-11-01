// § pkgTdForeignSpecParams460 (control: typedef in a class)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  class holder;
    typedef S #(a_item) a_seqr;
    a_seqr h;
  endclass
endpackage
module top;
  import a::*;
  holder h;
  initial h = new;
endmodule
