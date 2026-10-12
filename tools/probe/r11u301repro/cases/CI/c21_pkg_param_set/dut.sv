// § caInsideRhsClonesCell301
package pk;
  localparam logic [3:0] P = 4'd5;
endpackage
module dut (input logic [3:0] a, output logic o);
  assign o = a inside {pk::P, [4'd8:4'd9]};
endmodule
