// § rawEndLineModel295
module top(output logic [7:0] o);
  logic [7:0] \b.c = 8'h1; logic [7:0] d = \b.c ;
  assign o = d;
endmodule
