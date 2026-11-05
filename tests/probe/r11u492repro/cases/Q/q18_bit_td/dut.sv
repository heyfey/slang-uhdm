// a bit-vector typedef, qualified formal
package zp;
  typedef bit [3:0] zt_t;
endpackage
package ap;
  function int af (zp::zt_t a);
    return int'(a);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(4'h1);
endmodule
