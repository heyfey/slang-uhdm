// § caUserCallRhsNotReduced276
function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
module dut (output logic [31:0] o [2]);
  localparam logic [11:0] K = 12'hFFF;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = f(K);
  end
endmodule
