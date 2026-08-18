// v93 A3 — numeric / expression / absent slice sizes (the untouched shapes).
module a3_num;
  parameter int WREN = 7;
  logic [63:0] v, r;
  initial begin
    r = { << 6        { v } };
    r = { << 32       { v } };
    r = { << 8'd4     { v } };
    r = { << (WREN+2) { v } };
    r = { << WREN + 2 { v } };
    r = { <<          { v } };
    r = { >>          { v } };
    r = { >> 3        { v } };
  end
endmodule
