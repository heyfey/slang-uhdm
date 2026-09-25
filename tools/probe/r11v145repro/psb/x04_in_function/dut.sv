// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [4:0] o);
  localparam int W = 8;
  localparam int L = 4;
  function automatic logic [4:0] f(logic [31:0] x);
    return x[W:L];
  endfunction
  assign o = f(a);
endmodule
