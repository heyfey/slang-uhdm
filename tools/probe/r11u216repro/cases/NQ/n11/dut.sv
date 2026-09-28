// § ndaRangeQueryFold216 — $high of a logic variable in a net initializer, a variable initializer beside it (control)
module dut (output logic [3:0] o, output logic [3:0] o2);
  logic [9:7] v;
  wire [3:0] w = $high(v);
  logic [3:0] u = $high(v);
  assign o = w;
  assign o2 = u;
endmodule
