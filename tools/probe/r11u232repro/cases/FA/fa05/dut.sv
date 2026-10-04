// § caCallArgParamFormalTs232
package q;
  function automatic int unsigned w(logic [7:0] x);
    return x + 1;
  endfunction
endpackage
module sub #(parameter int unsigned N = 1) (output logic [q::w(N)-1:0] o);
  assign o = '1;
endmodule
module top(output logic [4:0] o);
  sub #(.N(4)) u (.o(o));
endmodule
