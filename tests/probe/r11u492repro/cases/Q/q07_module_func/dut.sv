// a MODULE function with a qualified formal
package zp;
  typedef logic [7:0] zb_t;
endpackage
module m;
  function int mf (zp::zb_t a);
    return int'(a);
  endfunction
  int r;
  initial r = mf(8'h1);
endmodule
