// § callOpArgNotReadEither276v
module dut (input logic [31:0] n, output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); return x + n; endfunction
  localparam logic [11:0] K = 12'h0F0;
  assign o = f(K[7:0] + 8'd1);
endmodule
