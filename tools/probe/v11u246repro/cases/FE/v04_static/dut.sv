// § foreachLocalArrTsOwnListing246
package p;
  localparam int W = 12;
  localparam int N = $clog2(W) + 1;
  typedef bit unsigned [W-1:0] w_t;
  function automatic int f();
    static w_t sa[N];
    int acc;
    foreach (sa[i]) acc += sa[i][W-1 -: 2] + {2{sa[i][0]}};
    return acc;
  endfunction
  class c;
    task t();
      w_t ta[];
      fork
        begin
          foreach (ta[k]) ta[k] = ta[k][N:0];
        end
      join
    endtask
  endclass
endpackage
module top;
  import p::*;
  int r;
  initial r = f();
endmodule
