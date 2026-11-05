// no call, no module use
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
endmodule
