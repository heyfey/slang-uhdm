// § unitTdLawS245
// a $unit vector typedef on a program variable
typedef logic [3:0] nib_t;
program pg(input logic [3:0] i);
  nib_t v;
  initial v = i;
endprogram
module top(input logic [3:0] i);
  pg u(.i(i));
endmodule
