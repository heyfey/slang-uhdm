// § specifyRefNoDefNet422
// an implicit net in specify that a named gate output drives, in a child instance
module ch(input a, b, c, d, output q);
  and g1 (en, a, b);
  buf (q, d);
  specify
    $hold(posedge c &&& en, d, 3);
  endspecify
endmodule
module top(input a, b, c, d, output q);
  ch u(a, b, c, d, q);
endmodule
