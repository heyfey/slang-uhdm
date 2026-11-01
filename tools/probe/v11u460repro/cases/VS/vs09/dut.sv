// § pkgTdForeignSpecParams460 (control: module typedef)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
endpackage
module top;
  import u::*;
  class m_item extends item; endclass
  typedef S #(m_item) m_seqr;
  m_seqr h;
  initial h = new;
endmodule
