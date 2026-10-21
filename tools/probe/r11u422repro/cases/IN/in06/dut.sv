// § specifyRefNoDefNet422
module top(input a, b, c, d, output q);
  and (en, a, b);
  specify
    (a => q) = 1;
  endspecify
  buf (q, en);
endmodule
