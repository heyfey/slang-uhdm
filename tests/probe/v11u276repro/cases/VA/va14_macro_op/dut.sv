// § callOpArgNotReadEither276v
`define KP1 (K + 12'h1)
module dut (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'h0F0;
  assign o = f(`KP1);
endmodule
