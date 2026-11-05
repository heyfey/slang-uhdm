// a byte typedef, qualified formal, with a module variable
package zp;
  typedef byte zy_t;
endpackage
package ap;
  function int af (zp::zy_t a);
    return int'(a);
  endfunction
endpackage
module m;
  zp::zy_t v;
  int r;
  initial r = ap::af(v);
endmodule
