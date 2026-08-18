// v93 A8b — lexical layout between `<<`, the type token and the `{`.
// (`logic [7:0]` / `bit [3:0]` slice sizes are ILLEGAL SV -- removed.)
module a8b_layout;
  typedef logic [7:0] lt8;
  logic [63:0] v, r;
  initial begin
    r = {<<int{v}};
    r = { <<int { v } };
    r = { << int{ v } };
    r = { << int
          { v } };
    r = { << int /*c*/ { v } };
    r = { << /*c*/ int { v } };
    r = { << lt8{v} };
    r = { << 	int	{ v } };
  end
endmodule
