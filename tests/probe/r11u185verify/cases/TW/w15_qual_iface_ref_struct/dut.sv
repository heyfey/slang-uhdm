// § tfArgQualOutsideWriter176
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
endpackage
interface ifc;
  task automatic t(ref p::s_t v);
    v.b = 1'b1;
  endtask
endinterface
module top;
  ifc u();
  p::s_t x;
  initial u.t(x);
endmodule
