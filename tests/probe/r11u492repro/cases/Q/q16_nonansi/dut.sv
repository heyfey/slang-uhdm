// non-ANSI formal declaration (tf item, not the port list)
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function int af;
    input zp::zb_t a;
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1);
endmodule
