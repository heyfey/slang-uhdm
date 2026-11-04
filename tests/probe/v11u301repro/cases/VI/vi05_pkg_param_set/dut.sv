// § caInsideRhsClonesCell301
package pk;
  localparam int A = 3;
  localparam int B = 7;
endpackage
module child (input logic [3:0] a, output logic o);
  assign o = a inside {pk::A, pk::B};
endmodule
module dut (input logic [3:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
