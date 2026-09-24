// § constCallNameSpan137
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  function automatic int g(input int x); return x * 2; endfunction
  if (f(g(1)) == 3) begin : a
    assign o = 4'd1;
  end else begin : b
    assign o = 4'd2;
  end
endmodule
