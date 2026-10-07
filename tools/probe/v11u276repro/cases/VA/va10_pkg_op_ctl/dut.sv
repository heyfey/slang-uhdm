// § callOpArgNotReadEither276v
package q; function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction endpackage
module dut (output logic [31:0] o);
  localparam logic [11:0] K = 12'h0F0;
  assign o = q::f(K + 1);
endmodule
