// § constCallNameSpan137
module top #(parameter int P = 2)(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  if (P == 1) begin : g
    assign o = 4'd1;
  end else if (f(P) == 3) begin : h
    assign o = 4'd2;
  end else begin : k
    assign o = 4'd3;
  end
endmodule
