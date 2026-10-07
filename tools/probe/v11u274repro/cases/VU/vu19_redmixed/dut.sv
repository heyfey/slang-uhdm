// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter logic A = |4'h0;
  parameter logic B = ^4'h7;
  parameter logic C = ~&4'hF;
  parameter logic D = ~|4'h0;
  parameter logic E = ~^4'h7;
endpackage
module dut(output logic [4:0] o); assign o = {pk::A, pk::B, pk::C, pk::D, pk::E}; endmodule
