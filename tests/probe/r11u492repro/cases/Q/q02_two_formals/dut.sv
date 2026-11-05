// two qualified formals: the last one is the last writer
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function int af (zp::zb_t a, zp::zb_t b);
    return int'(a) + int'(b);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1, 8'h2);
endmodule
