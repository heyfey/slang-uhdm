// § unitTdLawS245
// a $unit unranged bit typedef on a module variable
typedef bit b_t;
module top(input bit i, output bit o);
  b_t v;
  assign v = i;
  assign o = v;
endmodule
