// v93 A1 — every simple_type keyword as slice_size, one home (module initial).
module a1_types;
  logic [63:0] v;
  logic [63:0] r;
  initial begin
    r = { << byte      { v } };
    r = { << shortint  { v } };
    r = { << int       { v } };
    r = { << integer   { v } };
    r = { << longint   { v } };
    r = { << bit       { v } };
    r = { << logic     { v } };
    r = { << reg       { v } };
    r = { << time      { v } };
    r = { << realtime  { v } };
    r = { << real      { v } };
    r = { << shortreal { v } };
    r = { >> byte      { v } };
    r = { >> int       { v } };
    r = { >> logic     { v } };
    r = { >> time      { v } };
    r = { >> real      { v } };
  end
endmodule
