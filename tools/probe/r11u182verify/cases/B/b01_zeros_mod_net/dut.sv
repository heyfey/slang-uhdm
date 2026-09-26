// § boundLitWrittenDigits172
module dut (input logic [007:000] a, output logic [00:00] o);
  logic [007:0] n;
  logic [03:00] m;
  assign n = a;
  assign m = a[3:0];
  assign o = n[0] ^ m[0];
endmodule
