// v97 va4 -- INTEGER-KIND TYPESPEC FACES THAT MUST NOT MOVE.  A struct member,
// a union member, a class property, an enum with an int base, a packed array of
// int, a function return and argument, a port of type int, a variable, a
// gen-scope declaration and an interface -- none of these is a cast target, so
// none may change.
package pva4;
  typedef struct packed { int a; int unsigned b; } stva4;
  typedef union packed { int u1; logic [31:0] u2; } unva4;
  typedef enum int { E0 = 0, E1 = 1 } eva4;
  typedef int pa4 [3];
endpackage
interface ifva4;
  int  ii;
  int unsigned iu;
endinterface
class cva4;
  int          cp;
  int unsigned cpu;
  function int cf(int arg);
    return arg + cp;
  endfunction
endclass
module topva4 import pva4::*; (input int pin, output int pout);
  ifva4 u_if();
  stva4 sv;
  unva4 uv;
  eva4  ev;
  pa4   av;
  int   vi;
  int unsigned viu;
  int signed   vis;
  logic [31:0] q;
  function automatic int fva4(int a, int unsigned b);
    return a + int'(b);
  endfunction
  for (genvar gi = 0; gi < 2; gi++) begin : gb
    int gvi;
    int unsigned gviu;
  end
  assign pout = fva4(vi, viu) + vis + int'(ev) + sv.a + uv.u1 + av[0] + pin
              + u_if.ii + gb[0].gvi;
  assign q = 32'(vi);
endmodule
