// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o);
  localparam int L = 8'sh11;
  function automatic int f();
    localparam int F = 8'sh22;
    return F + L;
  endfunction
  assign o = f();
endmodule
