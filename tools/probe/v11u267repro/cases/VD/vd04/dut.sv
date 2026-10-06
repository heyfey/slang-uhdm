// § pkgQualPatConnSpan267
package pp;
  typedef struct packed { logic a; logic [3:0] w; } req_t;
  parameter req_t REQ_DEFAULT = '{a: 1'b1, w: 4'h3};
endpackage
interface ifc (input pp::req_t s);
  logic o;
  assign o = s.a;
endinterface
program pg (input pp::req_t s, output logic o);
  assign o = s.a;
endprogram
module top(output logic o, output logic o2);
  ifc u_i(pp::REQ_DEFAULT);
  pg u_p(.s(pp::REQ_DEFAULT), .o(o2));
  assign o = u_i.o;
endmodule
