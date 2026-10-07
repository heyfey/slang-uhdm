// § defNetTpDimLastInstPat275 — an interface with a named-element array type parameter
interface ifc #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) ();
  rt_t x;
endinterface
module dut (input logic [15:0] a, output logic [15:0] o);
  ifc #(.id_t(logic [1:0])) u ();
  assign u.x = a;
  assign o = u.x;
endmodule
