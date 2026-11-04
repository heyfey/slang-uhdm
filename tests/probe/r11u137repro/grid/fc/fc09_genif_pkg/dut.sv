// § constCallNameSpan137
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top(output logic [3:0] o);
  if (q::w(2) == 3) begin : g
    assign o = 4'd1;
  end else begin : h
    assign o = 4'd2;
  end
endmodule
