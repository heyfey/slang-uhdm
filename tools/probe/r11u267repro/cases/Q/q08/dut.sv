// § pkgQualPatConnSpan267
package pp;
  typedef struct packed { logic x; logic y; } in_t;
  typedef struct packed { in_t i; logic [3:0] w; } req_t;
  parameter req_t REQ_DEFAULT = '{
    i: '{x: 1'b1, y: 1'b0},
    w: 4'h3
  };
endpackage
module pm (input pp::req_t r, output logic o);
  assign o = r.i.x;
endmodule
module top(output logic o);
  pm u_pm(.r(pp::REQ_DEFAULT), .o(o));
endmodule
