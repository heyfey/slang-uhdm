// § pkgTdForeignSpecParams460 (bare typedef S with defaults)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
endpackage
package a;
  import u::*;
  typedef S a_seqr;
endpackage
module top;
  import a::*;
  a_seqr h;
  initial h = new;
endmodule
