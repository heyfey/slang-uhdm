// t9: one keyword, TWO type declarators (the second inherits the keyword);
// a bound reading ANOTHER type parameter's width through $bits; and a
// type parameter whose default is a TYPEDEF-named vector (no dims of its own).
module dut #(
    parameter  int  WA = 9,
    parameter  type PA = logic [WA-1:0], PB = logic [WA-2:0],
    parameter  type PC = logic [$bits(PA)-1:0]
) (input PA a, input PB b, input PC c, output logic o);
  typedef logic [WA-1:0] vec_t;
  localparam type PD = vec_t;
  PD d;
  assign o = ^{a,b,c,d};
endmodule
