// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o);
  localparam int P = 8'sd9;
  function automatic int f(int a); return a + P; endfunction
  assign o = f(1);
endmodule
