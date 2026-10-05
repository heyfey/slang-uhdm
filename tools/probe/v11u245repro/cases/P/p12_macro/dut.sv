// § unitPredefTd245
// a $unit int typedef written inside a macro body
`define TD(t, n) typedef t n;
`TD(int, ui_t)
module top(input int i, output int o);
  ui_t v;
  assign v = i;
  assign o = v;
endmodule
