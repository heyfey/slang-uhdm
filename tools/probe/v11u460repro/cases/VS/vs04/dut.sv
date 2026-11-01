// § pkgTdForeignSpecParams460 (generic class reached through an export)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
endpackage
package m;
  import u::S;
  import u::item;
  export u::S;
  export u::item;
endpackage
package a;
  import m::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
module top;
  import a::*;
  a_seqr h;
  initial h = new;
endmodule
