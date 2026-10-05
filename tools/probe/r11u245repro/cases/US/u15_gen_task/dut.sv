// § unitTdLawS245
// $unit typedefs inside a generate block and a module task with a byte typedef
typedef byte uby_t;
typedef logic [3:0] nib_t;
module top;
  if (1) begin : g
    nib_t gv;
    uby_t gb;
  end
  task automatic t(input uby_t a, output nib_t b); b = a; endtask
  nib_t r;
  initial t(8'h3, r);
endmodule
