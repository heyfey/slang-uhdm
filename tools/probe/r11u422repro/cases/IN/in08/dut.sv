// § specifyRefNoDefNet422
module sub(input x, output y);
  assign y = x;
endmodule
module top(input a, b, output q);
  sub s(w, q);
  buf (q, a);
endmodule
