// § constCallNameSpan137
module top #(parameter int P = 2)(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  for (genvar i = 0; i < 1; i++) begin : l
    if (f(P) == 3) begin : g
      assign o = 4'd1;
    end else begin : h
      assign o = 4'd2;
    end
  end
endmodule
