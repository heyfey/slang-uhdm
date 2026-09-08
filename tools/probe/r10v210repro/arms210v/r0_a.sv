// R0 reproducer attempt A — a parameterized class extending a parameterized
// base with the type parameter FORWARDED, with a local of the type-parameter
// type in a method, specialized from a module.
package r0apkg;
  class base_c #(type T = int);
    T b;
  endclass
  class seqr_c #(type REQ = int, type RSP = REQ) extends base_c #(REQ);
    function void stop_sequences();
      REQ t;
      t = t;
    endfunction
  endclass
endpackage
module r0amod;
  import r0apkg::*;
  seqr_c #(int) u;
endmodule
