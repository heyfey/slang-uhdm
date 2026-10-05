// § foreachLocalArrTsOwnListing246
package p;
  typedef bit [32-1:0] w_t;
  class c;
    function void m();
      w_t a[];
      foreach (a[i]) a[i] = i;
      foreach (a[j]) a[j] = a[j] + 1;
    endfunction
  endclass
endpackage
module top;
endmodule
