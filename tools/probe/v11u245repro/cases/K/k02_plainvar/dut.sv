// § unitLawSSkipAliasedListing245v
// a $unit packed array of a $unit typedef on a module variable and a wire
typedef logic [1:0] e_t;
typedef e_t [3:0] arr_t;
module top(input logic [7:0] a, output logic [7:0] o);
  arr_t x;
  wire arr_t w = x;
  assign x = a;
  assign o = w;
endmodule
