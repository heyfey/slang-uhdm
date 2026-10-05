// § foreachLocalArrTsOwnListing246
package p;
  typedef bit unsigned [16-1:0] h_t;
  class pc #(int W = 8);
    extern function void m();
  endclass
  function void pc::m();
    h_t a[];
    bit [W-1:0] b[$];
    foreach (a[i]) a[i] = W;
    foreach (b[i]) b[i] = {W{1'b1}};
  endfunction
endpackage
module top;
  p::pc #(4) h;
  initial h = new;
endmodule
