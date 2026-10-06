// § pkgQualPatConnSpan267
package pp;
  typedef struct packed { logic a; logic [3:0] w; } req_t;
  parameter req_t REQ_DEFAULT = '{a: 1'b1, w: 4'h3};
endpackage
module pm (input pp::req_t s, output logic o);
  assign o = s.a;
endmodule
module top(output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    pm u_a(pp::REQ_DEFAULT, o[i]);
  end
endmodule
