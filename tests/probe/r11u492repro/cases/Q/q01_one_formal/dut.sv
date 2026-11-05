// one package-qualified vector-typedef formal of another package's function
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h1);
endmodule
