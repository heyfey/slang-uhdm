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
// the call as a replication count with a net operand, and under a unary reduction
module sub #(parameter int unsigned N = 1) (input logic x, output logic [15:0] o, output logic r);
  assign o = {q::w(N){x}};
  assign r = ^q::w(N);
endmodule
module top(input logic x, output logic [15:0] o, output logic r);
  sub #(.N(3)) u (.x(x), .o(o), .r(r));
endmodule
