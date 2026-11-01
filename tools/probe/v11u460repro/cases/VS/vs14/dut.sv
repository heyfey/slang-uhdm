// § clsNestedSpecCloneHomeInst460 (no importer package: the module uses the specialization)
package u;
  class item; endclass
  class S #(type REQ = item);
    typedef S #(REQ) this_type;
    REQ r;
  endclass
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
module top;
  import a::*;
  a_seqr h;
  initial h = new;
endmodule
