// § rawEndLineModel295
module child (input logic [7:0] \p.a [0:1], output logic [7:0] o); assign o = \p.a [0]; endmodule
module dut (input logic [7:0] i [0:1], output logic [7:0] o);
  child u (.\p.a (i), .o(o));
endmodule
