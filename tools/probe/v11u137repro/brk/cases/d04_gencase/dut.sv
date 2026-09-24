// § constCallNameSpan137
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  case (f(2))
    3: begin : a assign o = 4'd1; end
    default: begin : b assign o = 4'd2; end
  endcase
endmodule
