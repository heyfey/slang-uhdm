// § caCallArgParamFormalTs232
package q;
  function automatic int unsigned w(logic [7:0] x, int unsigned y);
    return x + y;
  endfunction
endpackage
module sub #(parameter int unsigned N = 1, parameter int unsigned K = 2) (output logic [q::w(N, K)-1:0] o);
  assign o = '1;
endmodule
module top(output logic [6:0] o);
  sub #(.N(4), .K(3)) u (.o(o));
endmodule
