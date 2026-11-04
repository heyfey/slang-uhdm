// § tfArgQualOutsideWriter176
package q;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
module top;
  task automatic t(inout q::s_t x);
    x.a = x.a + 1;
  endtask
  q::s_t v;
  initial t(v);
endmodule
