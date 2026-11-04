// § modArrConcatInitElemSize430
module top(output logic [7:0] o);
  byte tab[2] = { 8'h1, 2 };
  assign o = tab[0];
endmodule
