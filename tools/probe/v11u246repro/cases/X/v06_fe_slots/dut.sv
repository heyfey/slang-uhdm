// § foreachLocalArrTsOwnListing246
package p;
  localparam int W = 16;
  typedef bit unsigned [W-1:0] w_t;
  class c;
    extern function void m(int k);
  endclass
  function void c::m(int k);
    w_t a[];
    bit [31:0] r;
    foreach (a[i]) begin
      r = {2{a[i][W-1 -: 8]}};
      r[i +: 4] = a[i][3:0];
      r[W/2-1:0] = a[i][W-1:W/2];
    end
  endfunction
endpackage
module top;
endmodule
