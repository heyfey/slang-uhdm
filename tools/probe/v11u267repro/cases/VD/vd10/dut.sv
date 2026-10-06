// § pkgQualPatConnSpan267
typedef struct packed { logic a; logic [3:0] w; } req_t;
parameter req_t REQ_DEFAULT = '{a: 1'b1, w: 4'h3};
module pm (input req_t s, output logic o);
  assign o = s.a;
endmodule
module top(output logic o, output logic o2);
  pm u_a(.s($unit::REQ_DEFAULT), .o(o));
  pm u_b($unit::REQ_DEFAULT, o2);
endmodule
