// § tfItemInitLocalAtType209: two declarators, dims, qualifiers
package q;
  typedef logic [3:0] n_t;
  function automatic int h;
    int a = 1, b = 2;
    int arr [2] = '{1, 2};
    const int c = 4;
    automatic int d = 5;
    n_t e = 4'd3;
    q::n_t f = 4'd1;
    var int g = 6;
    return a + b + arr[0] + c + d + e + f + g;
  endfunction
endpackage
module top;
  int r;
  initial r = q::h();
endmodule
