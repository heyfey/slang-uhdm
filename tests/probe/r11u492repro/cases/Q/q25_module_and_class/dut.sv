// a module function writer and a module class method writer
package zp;
  typedef logic [7:0] zb_t;
endpackage
module m;
  class c;
    function int cf (zp::zb_t a);
      return int'(a);
    endfunction
  endclass
  function int mf (zp::zb_t a);
    return int'(a);
  endfunction
  c h;
  int r;
  initial begin h = new; r = h.cf(8'h1) + mf(8'h2); end
endmodule
