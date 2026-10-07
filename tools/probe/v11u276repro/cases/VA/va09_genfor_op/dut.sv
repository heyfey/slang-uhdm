// § callOpArgNotReadEither276v
module dut (output logic [31:0] o [2]);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'h0F0;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = f(K + i);
  end
endmodule
