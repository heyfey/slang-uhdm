// § pkgQualBoundSpanTernary298
// the select in a module instantiated three levels down with a parameter condition
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam int N = 3;
  localparam int M = 5;
endpackage
module leaf #(parameter int W = 1) (input logic [31:0] d, output logic [31:0] y);
  assign y = 32'(d[(W > 1 ? pk::N : pk::M):0]);
endmodule
module mid (input logic [31:0] d, output logic [31:0] y);
  leaf #(.W(2)) l (.d(d), .y(y));
endmodule
module top (input logic [31:0] d, output logic [31:0] y);
  mid m (.d(d), .y(y));
endmodule
