// a package function writer, then a module function writer
package zp;
  typedef logic [7:0] zb_t;
endpackage
module m;
  function int mf (zp::zb_t a);
    return int'(a);
  endfunction
  int r;
  initial r = mf(8'h1) + ap::af(8'h2);
endmodule
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
