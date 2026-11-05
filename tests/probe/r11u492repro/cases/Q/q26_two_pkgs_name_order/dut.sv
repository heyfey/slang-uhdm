// two importer packages, the later one in the file sorts first by name
package zp;
  typedef logic [7:0] zb_t;
endpackage
package yp;
  function int yf (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
package bp;
  function int bf (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = yp::yf(8'h1) + bp::bf(8'h2);
endmodule
