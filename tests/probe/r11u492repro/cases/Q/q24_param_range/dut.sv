// a vector typedef whose range reads a package parameter
package zp;
  parameter int W = 8;
  typedef logic [W-1:0] zb_t;
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
