// § constCallNameSpan137
module sub #(parameter int W = 1)(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  if (f(W) == 3) begin : a
    assign o = 4'd1;
  end else begin : b
    assign o = 4'd2;
  end
endmodule
module top(output logic [3:0] o1, o2);
  sub #(.W(2)) u1(.o(o1));
  sub #(.W(5)) u2(.o(o2));
endmodule
