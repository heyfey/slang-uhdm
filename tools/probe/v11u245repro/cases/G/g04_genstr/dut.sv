// § unitLawSGenVarIsInstVar245v
// a $unit string typedef variable inside a generate block of a child module
typedef string us_t;
module sub;
  if (1) begin : g
    us_t s;
  end
  initial g.s = "x";
endmodule
module top;
  sub u();
endmodule
