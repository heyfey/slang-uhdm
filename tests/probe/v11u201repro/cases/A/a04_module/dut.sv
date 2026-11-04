// § newArrayArgPathElemsStripped200
module top;
  typedef struct { int size; } s_t;
  s_t s;
  int q[$];
  byte d[];
  initial begin
    d = new[s.size];
    d = new[q.size + s.size];
    d = new[s.size - 1](d);
  end
endmodule
