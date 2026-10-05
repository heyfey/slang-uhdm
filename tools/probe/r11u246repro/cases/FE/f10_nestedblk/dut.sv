// § foreachLocalArrTsOwnListing246
package p;
  typedef bit [32-1:0] w_t;
  class c;
    function void m(int k);
      if (k > 0) begin
        w_t a[];
        foreach (a[i]) a[i] = i;
      end
    endfunction
  endclass
endpackage
module top;
endmodule
