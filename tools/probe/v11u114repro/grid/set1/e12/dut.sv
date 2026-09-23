// unqualified read, P imported, but P is also a package-local enum-valued concat
package pk; typedef enum logic [3:0] {A=4'h1, B=4'h2} e_t; parameter logic [7:0] P = {A, B}; endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y);
  always_ff @(posedge x[0]) case (x) P: y <= 4'd1; default: y <= 4'd0; endcase
endmodule
