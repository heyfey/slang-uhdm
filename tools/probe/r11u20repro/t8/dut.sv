// t8: non-logic element classes and signing -- bit, and a signed default,
// plus a bound whose element is a TYPEDEF-named vector.
module dut #(
    parameter int         W  = 6,
    parameter type        B1 = bit [W-1:0],
    parameter type        S1 = logic signed [W-1:0],
    parameter type        I1 = int,
    parameter type        E1 = logic [W-1:0]
) (input B1 b, input S1 s, input I1 i, input E1 e, output logic o);
  assign o = ^{b,s,i,e};
endmodule
