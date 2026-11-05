// a package class method writer, then the package's own function in source order
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  class c;
    function int cf (zp::zb_t a);
      return int'(a);
    endfunction
  endclass
  function int af (zp::zb_t a);
    return int'(a);
  endfunction
endpackage
module m;
  ap::c h;
  int r;
  initial begin h = new; r = h.cf(8'h1) + ap::af(8'h2); end
endmodule
