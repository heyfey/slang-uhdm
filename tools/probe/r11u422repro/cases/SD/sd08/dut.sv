// § strNetRefMintsNet422
module sub(input i);
endmodule
module top(input d, g);
  trireg (large) c;
  sub s(.i(c));
endmodule
