// § ndaRangeQueryFold216 — an INT bound W-1 shared by two declarators: $high(a) resizes the bound in place (b reads it too?)
module dut #(parameter int W = 6) (output logic [7:0] o, output logic [W-1:0] o2);
  logic [W-1:0] a, b;
  wire [7:0] w = $high(a);
  assign o = w;
  assign o2 = b;
endmodule
