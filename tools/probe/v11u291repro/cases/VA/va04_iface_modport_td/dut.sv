// § anonAggMemberChainName291
typedef struct packed { struct packed { logic a; logic b; } [1:0] m; } t_t;
interface ifc;
  t_t d;
  modport mp (input d);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.d.m[1].a;
endmodule
module dut (input t_t a, output logic o);
  ifc i ();
  assign i.d = a;
  child u (.p(i), .o(o));
endmodule
