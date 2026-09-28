// § ndaSizeQueryFold216 — $size in a CRLF-free child instantiated in a generate loop, and a macro-written $size
`define SZ(x) $size(x)
module sub (input logic [6:2] i, output logic [7:0] o, output logic [7:0] o2);
  wire [7:0] w = $size(i);
  wire [7:0] x = `SZ(i);
  assign o = w;
  assign o2 = x;
endmodule
module dut (input logic [6:2] i, output logic [7:0] o [2], output logic [7:0] p [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    sub u (.i(i), .o(o[k]), .o2(p[k]));
  end
endmodule
