// § aliasElemDynTd406
module top;
  typedef byte b_t;
  typedef b_t d_t [];
  d_t x, y;
  initial x = new[2];
endmodule
