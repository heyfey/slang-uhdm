// § pkgQualOperandSpanInParam218
package p; localparam int A = 3; endpackage
module top(output logic [5:0] o);
  for (genvar g = 0; g < 1; g++) begin : gen
    localparam int L = p::A << 1;
    assign o = L;
  end
endmodule
