// § caseItemWildConcatOnly215 — an imported parameter with no initializer form (a type-derived value), a plain wildcard, a concatenation inside a replication
package tp;
  parameter logic [3:0] W1 = 4'b1?0?;
  parameter logic [7:0] W2 = {2{4'b01??}};
  parameter logic [7:0] W3 = {4'hx, 4'h3};
endpackage
module m import tp::*; (input logic [7:0] a, output logic o);
  always_comb begin
    o = 1'b0;
    casez (a)
      {4'h0, W1}: o = 1'b1;
      W2: o = 1'b1;
      W3: o = 1'b0;
      default: o = 1'b0;
    endcase
  end
endmodule
