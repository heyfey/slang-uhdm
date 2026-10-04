// § structCopyNestedAnnotDeep232
// three nesting levels set by a function; the parameter read in a localparam, a part-select bound and a replication count
package p;
  typedef struct packed { logic [3:0] k; logic f; } in_t;
  typedef struct packed { in_t i; logic [3:0] m; } mid_t;
  typedef struct packed { mid_t md; logic [3:0] n; } cfg_t;
  function automatic cfg_t mk();
    cfg_t c;
    c.md.i.k = 4'd5;
    c.md.i.f = 1'b1;
    c.md.m = 4'd2;
    c.n = 4'd3;
    return c;
  endfunction
endpackage
module child import p::*; #(parameter cfg_t C = '0) (input logic [15:0] a, output logic [3:0] o, output logic [7:0] r);
  localparam int K = C.md.i.k;
  assign o = a[C.md.m +: 4];
  assign r = {C.n{2'b01}} ^ K;
endmodule
module top(input logic [15:0] a, output logic [3:0] o, output logic [7:0] r);
  localparam p::cfg_t CF = p::mk();
  child #(.C(CF)) c (.a(a), .o(o), .r(r));
endmodule
