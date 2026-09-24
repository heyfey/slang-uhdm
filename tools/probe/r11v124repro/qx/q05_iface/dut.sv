// § pkgQualFoldSpanByView124
package pk; parameter int X = 5; endpackage
interface bi #(parameter int W = pk::X); logic [W-1:0] d; endinterface
module top(output logic [4:0] o); bi b(); assign b.d = '1; assign o = b.d; endmodule
