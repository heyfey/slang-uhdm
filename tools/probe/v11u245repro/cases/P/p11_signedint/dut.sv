// § unitPredefTd245
// a $unit shortint signed typedef and an integer unsigned typedef
typedef shortint signed ss_t;
typedef integer unsigned iu_t;
module top(input logic [15:0] i, output logic [15:0] o);
  ss_t a;
  iu_t b;
  assign a = i;
  assign b = a;
  assign o = b[15:0];
endmodule
