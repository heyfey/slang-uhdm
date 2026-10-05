// § unitLawSSkipAliasedListing245v
// a $unit packed array of a $unit typedef on a function formal, local and return
typedef bit [1:0] e_t;
typedef e_t [1:0] arr_t;
module top(input logic [3:0] a, output logic [3:0] o);
  function automatic arr_t f(arr_t v);
    arr_t t;
    t = ~v;
    return t;
  endfunction
  assign o = f(a);
endmodule
