// § specifyRefNoDefNet422
module top(input a, b, output q);
  and (en, a, b);
  buf (q, a);
endmodule
