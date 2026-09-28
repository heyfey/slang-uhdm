// § ndaRangeQueryFold216 — $left of an unpacked-array input (v11u212 e16 second net)
module dut (input logic [3:0] i [5], output logic [7:0] o);
  wire [7:0] l = $left(i);
  assign o = l;
endmodule
