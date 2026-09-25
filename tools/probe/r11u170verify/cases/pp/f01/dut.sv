// § pkgFoldLeftParenSpan158
package pk;
  localparam int A = 6;
  localparam int B = 3;
  localparam int P = ((A + 1)
                      ) * (B - 1);
endpackage
module top (output logic [pk::P-1:0] o); assign o = '0; endmodule
