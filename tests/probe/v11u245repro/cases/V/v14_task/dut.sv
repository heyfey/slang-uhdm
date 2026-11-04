// § unitTdLawS245
// a $unit vector typedef on a module task's input and output formals
typedef logic [3:0] nib_t;
module top(input logic [3:0] i, output logic [3:0] o);
  task automatic t(input nib_t a, output nib_t b);
    b = a ^ 4'h5;
  endtask
  always_comb t(i, o);
endmodule
