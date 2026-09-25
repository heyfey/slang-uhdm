// § builtinMethodArgNamedByPath154
module top;
  typedef struct { int k; string nm; } r_t;
  r_t r;
  string s = "abcd";
  byte c;
  assign c = s.getc(r.k);
endmodule
