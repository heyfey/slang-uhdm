// § sgnLitElabFreshIntTs266
class K;
  localparam int P = 12'shFFF;
  function int g(); return this.P; endfunction
endclass
module dut (output logic [63:0] o);
  assign o = 64'(K::P);
endmodule
