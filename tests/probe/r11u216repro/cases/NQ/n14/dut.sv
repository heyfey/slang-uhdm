// § ndaSizeQueryFold216 — $size of an unpacked-array input in a net initializer (v11u212 e16 first net)
module dut (input logic [3:0] i [5], output logic [7:0] o);
  wire [7:0] s = $size(i);
  assign o = s;
endmodule
