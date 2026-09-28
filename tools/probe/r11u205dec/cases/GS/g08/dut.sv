// r11u205 GS g08: an interface member with a genvar bit select in a generate-scope instance
interface bif;
  logic [3:0] d;
endinterface
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(output logic [3:0] o);
  bif b();
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(b.d[k]), .o(o[k]));
  end
endmodule
