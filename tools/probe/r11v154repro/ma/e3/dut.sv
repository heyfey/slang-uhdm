// § builtinMethodArgNamedByPath154
module top;
   typedef struct { string nm; } r_t;
   r_t r;
   string t = "ab";
   int b;
   assign b = r.nm.compare(t);
endmodule
