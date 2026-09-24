// g13 — the chain inside an INTERFACE parameter list.
interface ifc #(
    parameter type a_t = logic [4:0],
    parameter type b_t = a_t
) ();
  b_t x;
endinterface
module dut ( output logic o );
  ifc u();
  assign o = ^u.x;
endmodule
