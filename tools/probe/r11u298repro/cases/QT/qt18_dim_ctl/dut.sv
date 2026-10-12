// § pkgQualBoundSpanTernary298
// control: a ternary in a declaration dimension and a replication count
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
endpackage
module top (output logic [31:0] y);
  logic [(pk::DC ? pk::DC : pk::N)-1:0] v;
  assign v = '0;
  assign y = {{(pk::DC ? pk::N : pk::DC){1'b1}}, 29'(v)};
endmodule
