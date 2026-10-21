// § specifyRefNoDefNet422
// a module path and specparam; the implicit net only in a conditional path
module top(input a, b, c, output q);
  and (en, a, b);
  buf (q, c);
  specify
    specparam t = 2;
    if (en) (c => q) = t;
  endspecify
endmodule
