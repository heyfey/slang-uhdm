// § constCallNameSpan137
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top import q::*; #(parameter int P = 2)(output logic [3:0] o);
  if (w(P) == 3) begin : g
    assign o = 4'd1;
  end else begin : h
    assign o = 4'd2;
  end
endmodule
