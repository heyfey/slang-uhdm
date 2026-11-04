// § caCallArgParamFormalTs232
package q;
  function automatic int unsigned w(logic [7:0] x);
    return x + 1;
  endfunction
endpackage
module sub #(parameter int unsigned N = 1) (output logic [3:0] o);
  if (q::w(N) > 3) begin : g
    assign o = '1;
  end else begin : h
    assign o = '0;
  end
endmodule
module top(output logic [3:0] o);
  sub #(.N(4)) u (.o(o));
endmodule
