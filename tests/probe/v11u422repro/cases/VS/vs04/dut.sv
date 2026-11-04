// § strNetRefMintsNet422
// a small trireg read by always_comb and by a child's named port
module sub(input i, output o); assign o = i; endmodule
module top(input d, output reg o, output o2);
  trireg (small) w;
  always @* o = w;
  sub u(.i(w), .o(o2));
endmodule
