// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic o);
  function automatic logic [3:0] inc(input logic [3:0] x); return x + 1; endfunction
  assign o = inc(a) inside {[2:4]};
endmodule
