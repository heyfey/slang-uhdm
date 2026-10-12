// § varDeclInitMovesSharedTsEnd297
interface ifc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  var t_t x = 8'h11;
endinterface
module dut (output logic o);
  ifc u ();
  assign o = u.x.a[0];
endmodule
