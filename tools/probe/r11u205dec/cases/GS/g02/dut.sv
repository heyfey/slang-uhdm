// r11u205 GS g02: a genvar-indexed plain vector (no member) in a generate-scope instance
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input logic [3:0] w, output logic [3:0] o);
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(w[k]), .o(o[k]));
  end
endmodule
