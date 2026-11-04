// § modAliasPkgBaseTopView484v (interface task local of an interface alias of a package union)
package p;
  typedef union packed { logic [7:0] b; logic [7:0] c; } un_t;
endpackage
interface ifc;
  typedef p::un_t u2_t;
  logic [7:0] q;
  task t();
    u2_t a;
    a.b = 8'h3;
    q = a.c;
  endtask
endinterface
module top;
  ifc i();
  initial i.t();
endmodule
