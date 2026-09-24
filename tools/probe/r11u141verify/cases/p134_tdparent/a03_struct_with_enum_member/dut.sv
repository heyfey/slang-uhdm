// § typedefParentLastWriter134
// case a03: a package struct whose member is a package enum, imported by two modules
package p;
  typedef enum logic [1:0] { IDLE, RUN } st_e;
  typedef struct packed { st_e st; logic [5:0] cnt; } rec_t;
endpackage
module b_mod(output logic [7:0] o);
  import p::*;
  rec_t r;
  assign r.st = RUN;
  assign r.cnt = 6'd3;
  assign o = r;
endmodule
module a_mod(output logic [7:0] o);
  import p::rec_t;
  rec_t r2;
  assign r2 = 8'h0;
  assign o = r2;
endmodule
module top(output logic [7:0] o1, output logic [7:0] o2);
  a_mod a(.o(o1));
  b_mod b(.o(o2));
endmodule
