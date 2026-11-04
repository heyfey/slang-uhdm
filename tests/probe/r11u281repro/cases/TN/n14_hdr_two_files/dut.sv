// § defNetTpPatNestedSig281
`include "child.svh"
module dut(input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
