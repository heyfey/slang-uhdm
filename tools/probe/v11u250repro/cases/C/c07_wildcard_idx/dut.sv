// § pkgArrTdListing250
// associative typedefs indexed by byte, by a packed vector and by a wildcard, a size of 16 and a range written high to low
package p;
  typedef int ab_t [byte];
  typedef int av_t [bit [3:0]];
  typedef int aw_t [*];
  typedef bit [1:0] s16_t [16];
  typedef bit hl_t [7:4];
endpackage
module top;
  import p::*;
  ab_t x;
  av_t y;
  aw_t z;
  s16_t s;
  hl_t h;
  initial begin
    x[8'd1] = 1;
    y[4'd2] = 2;
    z[3] = 3;
    s[15] = 2'd1;
    h[5] = 1'b1;
  end
endmodule
