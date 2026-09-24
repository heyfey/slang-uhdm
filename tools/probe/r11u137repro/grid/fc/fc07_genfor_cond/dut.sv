// § constCallNameSpan137
module top(output logic [7:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  for (genvar i = 0; i < f(1); i++) begin : g
    assign o[i] = 1'b1;
  end
endmodule
