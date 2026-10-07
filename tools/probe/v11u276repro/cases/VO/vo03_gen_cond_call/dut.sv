// § elabRhsOwnTsNotDefFormal276
module dut (input logic [7:0] n, output logic [7:0] o);
  function automatic int f(logic [11:0] x); return x; endfunction
  parameter logic [11:0] K = 12'h005;
  if (f(K) > 3) begin : g
    assign o = n;
  end else begin : h
    assign o = ~n;
  end
endmodule
