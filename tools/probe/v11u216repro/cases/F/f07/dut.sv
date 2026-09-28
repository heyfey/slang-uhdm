// § ndaRangeQueryFold216 — a $clog2 bound $clog2(N)-1
module dut #(parameter int N = 16) (input logic [$clog2(N)-1:0] i, output logic [7:0] o);
  wire [7:0] w = $high(i);
  assign o = w;
endmodule
