// § foreachLocalArrTsOwnListing246
module top;
  typedef bit [32-1:0] w_t;
  function automatic void m();
    w_t a[];
    foreach (a[i]) a[i] = i;
  endfunction
  initial m();
endmodule
