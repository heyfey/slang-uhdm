// § ndaSysCallNetTs212 — r11u217 n08: net declarations initialized by `$size` and `$left` of a PARAMETERIZED vector in a child instantiated twice, and by `$bits` / `$clog2` (control)
module ch #(parameter int W = 4) (input logic [W-1:0] v, output logic [7:0] o);
  wire [7:0] s = $size(v);
  wire [7:0] l = $left(v);
  wire [7:0] b = $bits(v);
  wire [7:0] c = $clog2(W);
  assign o = s ^ l ^ b ^ c;
endmodule
module dut(input logic [7:0] v, output logic [7:0] o, output logic [7:0] p);
  ch u (.v(v[3:0]), .o(o));
  ch #(.W(8)) w (.v(v), .o(p));
endmodule
