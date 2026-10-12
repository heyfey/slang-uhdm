// § pkgQualBoundSpanTernary298
// control: a ternary in a bit-select index and an indexed part-select base
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (input logic [31:0] d, output logic y, output logic [3:0] z);
  always_comb begin
    y = d[pk::DC ? pk::DC : pk::N];
    z = d[(pk::DC ? pk::DC : pk::N) +: 4];
  end
endmodule
