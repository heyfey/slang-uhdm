// § newArrayArgPathElemsStripped200
package pk;
  typedef struct { int size; int w; } s_t;
  function automatic void fill(input s_t b, input int k);
    byte d[];
    d = new[b.size + 1];
    d = new[b.w * k];
  endfunction
endpackage
module top;
  import pk::*;
  s_t s;
  initial begin s.size = 2; s.w = 3; fill(s, 2); end
endmodule
