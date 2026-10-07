// § caUserCallRhsNotReduced276
module dut (output logic [31:0] o);
  localparam logic [11:0] K = 12'hFFF;
  if (1) begin : g
    function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
    assign o = f(K);
  end
endmodule
