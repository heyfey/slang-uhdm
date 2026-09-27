// § pkgAggTfArgCloneFollows180 (r11u190: a package union moved by a package TASK output formal, copied by two importers and a qualified parameter)
package p;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  task automatic put(output u_t u); u = 8'h1; endtask
  localparam u_t U = 8'h3C;
endpackage
module sub import p::*; #(parameter u_t V = U) (output logic [7:0] y);
  assign y = V.a;
endmodule
module top (output logic [7:0] y1, y2);
  localparam p::u_t W = 8'h77;
  sub u1(y1);
  sub #(.V(W)) u2(y2);
endmodule
