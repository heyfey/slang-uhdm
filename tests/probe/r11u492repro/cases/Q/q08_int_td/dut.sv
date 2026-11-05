// a scalar int typedef, qualified formal
package zp;
  typedef int zi_t;
endpackage
package ap;
  function int af (zp::zi_t a);
    return a;
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(1);
endmodule
