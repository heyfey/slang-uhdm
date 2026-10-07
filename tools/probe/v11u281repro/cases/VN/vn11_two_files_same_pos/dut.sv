// § defNetTpPatNestedSig281
`include "c1.svh"
`include "c2.svh"
module dut(input logic [7:0] a, output logic [7:0] o, output logic [7:0] p);
  child1 #(.id_t(logic [1:0])) u (.a(a), .o(o));
  child2 #(.id_t(bit [1:0])) v (.a(a), .o(p));
endmodule
