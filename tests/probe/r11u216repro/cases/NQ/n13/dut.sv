// § ndaSizeQueryFold216 — $size of a packed input in a written module assignment (control) and in a net initializer
module dut (input logic [5:2] i, output logic [7:0] o, output logic [7:0] o2);
  wire [7:0] w;
  assign w = $size(i);
  wire [2:0] v = $size(i);
  assign o = w;
  assign o2 = v;
endmodule
