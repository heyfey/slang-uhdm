// § sgnLitElabFreshIntTs266
module dut (output logic [63:0] o);
  localparam int P = 12'shFFF;
  function automatic int f(); return P; endfunction
  assign o = f();
endmodule
