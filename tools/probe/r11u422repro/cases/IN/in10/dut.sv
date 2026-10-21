// § specifyRefNoDefNet422
module top(input a, b, c, d, output q);
  pullup (en);
  buf (q, d);
  specify
    $setup(d, posedge c &&& en, 10);
  endspecify
endmodule
