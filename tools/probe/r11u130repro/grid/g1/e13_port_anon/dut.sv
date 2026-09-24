// § defNetEndOnlyLoc130
package pkg;
  typedef struct packed { logic a; logic b; } S;
endpackage
module sub(input pkg::S [1:0] p, output logic q);
  assign q = p[0].a;
endmodule
module top;
  pkg::S [1:0] w;
  logic q;
  sub u(.p(w), .q(q));
endmodule
