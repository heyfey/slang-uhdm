// v93 A4 — case / near-miss tokens.  None of these is a keyword.
module a4_case;
  typedef logic [7:0] INT;
  typedef logic [7:0] Int;
  typedef logic [7:0] int_t;
  typedef logic [7:0] tint;
  typedef logic [7:0] BIT;
  typedef logic [7:0] logic_t;
  typedef logic [7:0] Time;
  typedef logic [7:0] REAL;
  typedef logic [7:0] byte_;
  typedef logic [7:0] integer2;
  logic [63:0] v, r;
  initial begin
    r = { << INT      { v } };
    r = { << Int      { v } };
    r = { << int_t    { v } };
    r = { << tint     { v } };
    r = { << BIT      { v } };
    r = { << logic_t  { v } };
    r = { << Time     { v } };
    r = { << REAL     { v } };
    r = { << byte_    { v } };
    r = { << integer2 { v } };
  end
endmodule
