// § foreachLocalArrTsOwnListing246
package p;
  parameter int W = 16;
  typedef logic [W-1:0] d_t;
  class c;
    function void m();
      d_t a[];
      foreach (a[i]) a[i] = i;
    endfunction
  endclass
endpackage
module top;
endmodule
