// § elabCastSharesDeclRef154
module dut #(parameter int unsigned N = 4) (input logic x, output logic [3:0] o);
  localparam int SEL_W = $clog2(N);
  function automatic logic [3:0] f(input logic y); return y ? SEL_W'(1) : SEL_W'(3); endfunction
  assign o = f(x);
endmodule
