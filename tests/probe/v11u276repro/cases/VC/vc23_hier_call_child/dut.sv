// § caUserCallRhsNotReduced276
module sub; function automatic logic [31:0] f(logic [11:0] x); return x; endfunction endmodule
module dut (output logic [31:0] o);
  localparam logic [11:0] K = 12'hFFF;
  sub s();
  assign o = s.f(K);
endmodule
