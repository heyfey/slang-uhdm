// the home package's own function with a bare formal, an outside qualified writer
package zp;
  typedef logic [7:0] zb_t;
  function int zf (zb_t a);
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
  initial r = zp::zf(8'h1) + ap::af(8'h2);
endmodule
