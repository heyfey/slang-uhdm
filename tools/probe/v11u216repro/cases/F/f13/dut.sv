// § ndaRangeQueryFold216 — a hex bound onto a narrower net, the operand port read elsewhere
module dut (input logic [8'h0A:8'h03] i, output logic [2:0] o, output logic [7:0] o2);
  wire [2:0] w = $high(i);
  assign o = w;
  assign o2 = i;
endmodule
