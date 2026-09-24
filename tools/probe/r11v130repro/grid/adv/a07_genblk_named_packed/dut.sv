// § defNetEndOnlyLoc130
package pkg;
  typedef enum logic [1:0] {R, G} E;
endpackage
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    pkg::E [1:0] a;
    initial a = '{2{pkg::G}};
  end
endmodule
