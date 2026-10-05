// § foreachLocalArrTsOwnListing246
package p;
  localparam int LW = 3;
  typedef logic [LW*2-1:LW-3] l_t;
  class c;
    function void m();
      l_t a[2];
      foreach (a[i]) a[i] = '0;
    endfunction
  endclass
endpackage
module top;
endmodule
