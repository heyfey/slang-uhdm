// § specifyRefNoDefNet422
module top(input a, b, c, d, output q);
  and g (en, a, b);
  buf (q, d);
  specify
    $setup(d, posedge c &&& en2, 10);
  endspecify
endmodule
