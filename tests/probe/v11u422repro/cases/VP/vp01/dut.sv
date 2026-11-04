// § specifyRefNoDefNet422
// an implicit net in a specify condition that a continuous assign later also reads
module top(input a, b, c, d, output q, r);
  and (en, a, b);
  buf (q, d);
  specify
    $setup(d, posedge c &&& en, 10);
  endspecify
  assign r = en;
endmodule
