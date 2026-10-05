// § unitTdLawS245
// a $unit int typedef on a variable inside a generate block
typedef int ui_t;
module top(input int i, output int o);
  if (1) begin : g
    ui_t v;
    assign v = i;
  end
  assign o = g.v;
endmodule
