// § clsTdArrElemPkgPath249
package p;
  class c #(int W = 8);
    typedef logic [W-1:0] f_t[2];
    f_t m;
  endclass
endpackage
module top; p::c #(4) h; endmodule
