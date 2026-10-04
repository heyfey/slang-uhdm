// § caCallArgParamFormalTs232
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned cnt(mask_t cfg);
    int unsigned r = 0;
    for (int i = 0; i < 3; i++) if (cfg[i]) r++;
    return r;
  endfunction
  function automatic int unsigned w(int unsigned x);
    return x + 1;
  endfunction
  function automatic int unsigned w2(logic [7:0] x, int unsigned y);
    return x + y;
  endfunction
endpackage
module sub #(parameter int unsigned N = 1) (input logic [7:0] a, output logic o);
  assign o = a[q::w(N)];
endmodule
module top(input logic [7:0] a, output logic o);
  sub #(.N(4)) u (.a(a), .o(o));
endmodule
