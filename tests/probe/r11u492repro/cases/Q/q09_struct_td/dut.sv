// a packed struct typedef, qualified formal
package zp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } zs_t;
endpackage
package ap;
  function int af (zp::zs_t s);
    return int'(s.a);
  endfunction
endpackage
module m;
  int r;
  initial r = ap::af(8'h12);
endmodule
