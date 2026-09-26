// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, input logic [2:0] i);
  function automatic logic [2:0] f(input logic [2:0] x); return x + 3'd1; endfunction
  mod m(.a(v[f(i)]));
endmodule
