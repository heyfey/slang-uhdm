// § caUserCallRhsNotReduced276
function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
module dut (output logic [31:0] o);
  localparam logic [11:0] K = 12'hFFF;
  assign o = f(K);
endmodule
