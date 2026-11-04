// § tfArgQualOutsideWriter176
package q;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
endpackage
interface intf;
  function automatic logic [3:0] get(q::s_t x);
    return x.a;
  endfunction
endinterface
module top (input q::s_t si, output logic [3:0] o);
  intf i ();
  assign o = i.get(si);
endmodule
