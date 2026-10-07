// § pkgNetTsDimEnd274
package pk;
  wire [3:0] one = 4'h3;
  wire [1:0][1:0] two = 4'h5;
endpackage
module dut(output logic [3:0] o); assign o = pk::one ^ pk::two; endmodule
