// v18 — no shadow, but a typedef ELSEWHERE with the same canonical type as the
// chain source: pristine's canonical fallback names the WRONG typedef.
typedef logic [1:0] v_t;
module dut #(
    parameter type a_t = logic [1:0],
    parameter type b_t = a_t
) ( input b_t i, output logic o );
  assign o = ^i;
endmodule
