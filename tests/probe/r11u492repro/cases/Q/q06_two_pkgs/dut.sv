// two importer packages write the same typedef: which writer is last
package zp;
  typedef logic [7:0] zb_t;
endpackage
package bp;
  function int bf (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1) + bp::bf(8'h2);
endmodule
