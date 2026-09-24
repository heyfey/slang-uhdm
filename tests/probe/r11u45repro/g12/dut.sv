// g12 — non-logic keyword elements: int / real / string chained.
module dut #(
    parameter type i_t = int,
    parameter type j_t = i_t,
    parameter type r_t = real,
    parameter type s_t = r_t
) ( output logic o );
  j_t a; s_t b;
  assign o = (a == 0) && (b == 0.0);
endmodule
