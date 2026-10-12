// § pkgQualBoundSpanTernary298
// a ternary bound in an interface body and through an interface port
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
interface ifc; logic [31:0] d; logic [31:0] y; assign y = 32'(d[(pk::DC ? pk::DC : pk::N)-1:0]); endinterface
module top (input logic [31:0] a, output logic [31:0] b);
  ifc i ();
  assign i.d = a;
  assign b = 32'(i.d[(pk::N ? pk::DC : pk::N)-1:0]);
endmodule
