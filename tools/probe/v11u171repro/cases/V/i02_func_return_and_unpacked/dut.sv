// § boundLitWrittenDigits172
module dut(input logic [7:0] a, output logic [7:0] y);
  function automatic logic [007:000] f(input logic [07:0] x);
    return x;
  endfunction
  logic [7:0] m [00:01];
  assign m[0] = a;
  assign m[1] = f(a);
  assign y = m[0] ^ m[1];
endmodule
