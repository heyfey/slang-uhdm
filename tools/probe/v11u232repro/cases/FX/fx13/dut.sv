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
// the call as a part-select bound and an indexed part-select width, beside a net
module sub #(parameter int unsigned N = 1) (input logic [15:0] x, output logic [15:0] o, output logic [3:0] p);
  assign o = x[q::w(N):0];
  assign p = x[0 +: q::w(N)];
endmodule
module top(input logic [15:0] x, output logic [15:0] o, output logic [3:0] p);
  sub #(.N(3)) u (.x(x), .o(o), .p(p));
endmodule
