// § unitLawSSkipAliasedListing245v
// a $unit packed array of a $unit typedef as a type parameter's default, a body variable of the parameter
typedef logic [1:0] e_t;
typedef e_t [1:0] pr_t;
module top #(parameter type T = pr_t) (input T a, output logic [3:0] o);
  T x;
  assign x = a;
  assign o = x;
endmodule
