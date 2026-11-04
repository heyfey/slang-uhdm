// § namedTypeLocalTfItemOutsideClass426
interface ifc;
  typedef struct packed { logic [3:0] a; } box_t;
  function automatic logic [3:0] f;
    input logic [3:0] i;
    box_t r;
    r.a = i;
    f = r.a;
  endfunction
  modport mp(import f);
endinterface
module top;
  ifc u1();
  ifc u2();
endmodule
