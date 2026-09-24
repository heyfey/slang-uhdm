// v15 — a FOUR-deep chain: every link must reach the FIRST object.
module dut #(
    parameter type t1 = logic [2:0],
    parameter type t2 = t1,
    parameter type t3 = t2,
    parameter type t4 = t3
) ( input t4 i, output logic o );
  assign o = ^i;
endmodule
