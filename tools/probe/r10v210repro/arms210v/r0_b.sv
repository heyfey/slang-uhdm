// R0 reproducer attempt B — the type parameter defaults to a CLASS type
// declared in the same package (uvm_sequence_item's shape).
package r0bpkg;
  class item_c;
    int x;
  endclass
  class base_c #(type T = item_c);
    T b;
  endclass
  class seqr_c #(type REQ = item_c, type RSP = REQ) extends base_c #(REQ);
    function void stop_sequences();
      REQ t;
      t = t;
    endfunction
  endclass
endpackage
module r0bmod;
  import r0bpkg::*;
  seqr_c #(item_c) u;
endmodule
