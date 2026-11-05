// a class method in a package with a qualified formal
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  class c;
    function int cf (zp::zb_t a);
      return int'(a);
    endfunction
  endclass
endpackage
module m;
  ap::c h;
  int r;
  initial begin h = new; r = h.cf(8'h1); end
endmodule
