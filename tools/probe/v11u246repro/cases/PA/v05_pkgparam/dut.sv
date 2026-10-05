// § callArgParamCopyOwnTs246
package cfg;
  parameter int NP = 3;
  typedef int my_int_t;
endpackage
module sub import cfg::*; #(parameter my_int_t N = NP) (output logic [N-1:0][15:0] o);
  function automatic bit [N-1:0][15:0] f(int n);
    bit [N-1:0][15:0] r;
    for (int i = 0; i < n; i++) r[i] = {2{8'(i)}};
    return r;
  endfunction
  localparam bit [N-1:0][15:0] L = f(N);
  assign o = L;
endmodule
module top(output logic [2:0][15:0] o, output logic [3:0][15:0] o2);
  sub u(.o(o));
  sub #(.N(4)) u2(.o(o2));
endmodule
