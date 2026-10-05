// § unitTdLawS245
// the $unit typedef in one file, the module using it in another
module top(input logic [7:0] i, output logic [7:0] o);
  byte_t v;
  assign v = i;
  assign o = v;
endmodule
