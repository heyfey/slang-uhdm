// § newArrayArgPathElemsStripped200
module top;
  typedef struct { int n; } s_t;
  for (genvar g = 0; g < 2; g++) begin : gb
    s_t s;
    byte d[];
    initial begin
      d = new[s.n + g];
    end
  end
endmodule
