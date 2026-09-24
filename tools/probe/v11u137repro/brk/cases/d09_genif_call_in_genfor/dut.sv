// § constCallNameSpan137
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top(output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : l
    if (q::w(i) > 2) begin : a
      assign o[i] = 1'b1;
    end else begin : b
      assign o[i] = 1'b0;
    end
  end
endmodule
