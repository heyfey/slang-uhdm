// § importNetTsDimEnd275 — two packages, same declarator position, two modules
package p;
  logic [1:0][7:0] v;
endpackage
package q;
  logic [1:0][7:0] v;
endpackage
module a (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
module b (output logic [15:0] o);
  import q::*;
  assign o = v;
endmodule
module dut (output logic [15:0] o1, output logic [15:0] o2);
  a ua (.o(o1));
  b ub (.o(o2));
endmodule
