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
module sub #(parameter int unsigned N = 1) (output logic [7:0] o);
  assign o[q::w(N)] = 1'b1;
endmodule
module top(output logic [7:0] o);
  sub #(.N(4)) u (.o(o));
endmodule
