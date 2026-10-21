// § specifyRefNoDefNet422
module top(input a, b, c, d, output q);
  and (en, a, b);
  buf (q, en);
endmodule
