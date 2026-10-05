// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [32-1:0] w_t;
  class c;
    extern function void m();
  endclass
  function void c::m();
    w_t a[][];
    w_t b[4][2];
    foreach (a[i, j]) a[i][j] = i + j;
    foreach (b[i, j]) b[i][j] = b[i][j][3:0];
  endfunction
endpackage
module top;
endmodule
