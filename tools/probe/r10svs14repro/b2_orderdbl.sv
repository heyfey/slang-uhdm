// r10svs14 arm b2 — THE ORDER RULE, THE DOUBLING, AND THE RECEIVER KIND.
//
// b1 fixed the header-port kind and left three questions open, each of which can
// break a patch that copies the HOME view's Variables() onto the col-0 tail dup:
//
//   d1/d2  THE ORDER.  On the ANSI cells of b1 the header port is written FIRST,
//          so "the port var comes first" and "the list is in declaration order"
//          predict the SAME thing.  A NON-ANSI interface separates them: the port
//          NAME is in the header but its DECLARATION can sit AFTER a body
//          variable.  d1 declares the body var first, d2 the port first.
//   d3     THE DOUBLING.  An interface handed to an UNBOUND generic `interface`
//          port lists its variables TWICE, on the home view AND on the dup.  A
//          patch that copies the home list must not double a doubled list.
//   d4     THE RECEIVER KIND.  SVSwitch's receiver is a PROGRAM, not a module.
//   d5     NET-CLASS COMPANIONS.  A struct member (struct_net) and an unpacked
//          array (array_var) live next to the header port: the first must stay
//          OUT of Variables() and the second must stay IN, on both views.
//   d6     THE ARRAY OF INTERFACES (SVSwitch's output_intf[4] shape).

interface d1_if(clk);             // d1  body var declared BEFORE the port
  logic [7:0] dat;
  input bit clk;
  modport MP(input clk, output dat);
endinterface

interface d2_if(clk);             // d2  port declared BEFORE the body var
  input bit clk;
  logic [7:0] dat;
  modport MP(input clk, output dat);
endinterface

interface d3_if(input bit clk);  // d3  handed to an UNBOUND generic port
  logic [7:0] dat;
endinterface

interface d4_if(input bit clk);  // d4  handed to a PROGRAM
  logic [7:0] dat;
  modport MP(input clk, output dat);
endinterface

typedef struct packed { logic [3:0] a; logic [3:0] b; } d5_s;

interface d5_if(input bit clk);  // d5  struct + unpacked array companions
  d5_s        st;
  logic [7:0] arr [0:1];
  logic       pl;
  modport MP(input clk, output pl);
endinterface

interface d6_if(input bit clk);  // d6  instantiated as an ARRAY
  logic [7:0] dat;
  modport MP(input clk, output dat);
endinterface

module rx_d1(d1_if.MP p); endmodule
module rx_d2(d2_if.MP p); endmodule
module rx_gen(interface bus); endmodule          // UNBOUND: no `interface bus`
program rx_prog(d4_if.MP p); initial ; endprogram
module rx_d5(d5_if.MP p); endmodule
module rx_d6(d6_if.MP p [2]); endmodule

module top();
  bit Clock;

  d1_if e1(Clock);
  d2_if e2(Clock);
  d3_if e3(Clock);
  d4_if e4(Clock);
  d5_if e5(Clock);
  d6_if e6[2](Clock);

  rx_d1   x1(e1);
  rx_d2   x2(e2);
  rx_gen  x3(e3);
  rx_prog x4(e4);
  rx_d5   x5(e5);
  rx_d6   x6(e6);
endmodule
