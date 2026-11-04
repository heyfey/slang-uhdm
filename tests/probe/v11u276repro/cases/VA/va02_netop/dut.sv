// § callOpArgNotReadEither276v
module dut (input logic [31:0] n, output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  localparam logic [11:0] K = 12'h0F0;
  localparam logic [11:0] J = 12'h003;
  assign o = f(K & n[11:0]);
endmodule
