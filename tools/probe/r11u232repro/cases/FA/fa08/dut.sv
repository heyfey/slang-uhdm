// § caCallArgParamFormalTs232
module sub #(parameter int unsigned N = 1) (output logic [w(N)-1:0] o);
  function automatic int unsigned w(logic [7:0] x);
    return x + 1;
  endfunction
  assign o = '1;
endmodule
module top(output logic [4:0] o);
  sub #(.N(4)) u (.o(o));
endmodule
