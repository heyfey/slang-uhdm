// § ndaRangeQueryFold216 + § ndaSizeQueryFold216 — a CRLF file: a two-declarator net declaration with two queries, a parameter-sized operand
module dut #(parameter int N = 5) (input logic [N:2] a, output logic [7:0] o1, output logic [7:0] o2);
  wire [7:0] w1 = $high(a), w2 = $size(a);
  assign o1 = w1;
  assign o2 = w2;
endmodule
