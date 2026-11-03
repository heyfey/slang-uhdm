// § pkgVirtIfaceTd479 (control: a scalar typedef re-exported through an explicit export)
package t;
  typedef int i_t;
endpackage
package u;
  import t::i_t;
  export t::i_t;
endpackage
module top; import u::*; i_t h; endmodule
