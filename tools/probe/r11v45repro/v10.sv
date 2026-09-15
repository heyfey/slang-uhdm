// v10 (rewritten; the first spelling was illegal SV — slang rc=3) — the chain
// source is a PACKAGE-QUALIFIED typedef and the whole list lives in an
// INTERFACE that is actually INSTANTIATED.
package pk;
  typedef logic [2:0] p_t;
endpackage
interface intf #(
    parameter type a_t = pk::p_t,
    parameter type b_t = a_t
) ();
  b_t w;
  assign w = '0;
endinterface
module dut ( output logic o );
  intf #() i ();
  assign o = ^i.w;
endmodule
