// § unitVarRefMintsNet418
logic [7:0] g = 8'd5;
module sub (input logic [7:0] a, output logic [7:0] y);
  assign y = a;
endmodule
module top (output logic [7:0] o);
  sub u (.a(g), .y(o));
endmodule
