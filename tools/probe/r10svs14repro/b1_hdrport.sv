// r10svs14 arm b1 — WHICH HEADER-PORT VARIABLE DOES THE COL-0 TAIL DUP LIST?
//
// One axis only: the KIND of the interface's own HEADER PORT.  Everything else
// is held fixed — every interface carries a modport, every instance is passed
// WHOLE (a bare, dot-free connection expression) to a sibling module port, which
// is what makes Surelog mint the col-0 tail duplicate at all.
//
// The witness (SVSwitch) is cell c1: `input bit clock` + internal logic vars +
// a clocking block + `modport MP(clocking cb, input clock)`.
// The in-law control (InterfaceModPort's mem_if) is cell c2: `input wire clk`.

interface if_bit(input bit clock);            // c1  THE WITNESS SHAPE
  logic [7:0] d;
  logic       e;
  clocking cb@(posedge clock);
    default input #1 output #1;
    output d;
    output e;
  endclocking
  modport MP(clocking cb, input clock);
endinterface

interface if_wire(input wire clk);            // c2  InterfaceModPort's shape
  logic [7:0] d;
  logic       e;
  modport MP(input clk, output d, output e);
endinterface

interface if_logic(input logic clk);          // c3  4-state, no net keyword
  logic [7:0] d;
  modport MP(input clk, output d);
endinterface

interface if_int(input int n);                // c4  2-state INTEGER-typed port
  logic [7:0] d;
  modport MP(input n, output d);
endinterface

interface if_reg(output reg r);               // c5  reg-declared OUTPUT port
  logic [7:0] d;
  modport MP(output r, output d);
endinterface

interface if_multi(input bit a, input wire w, input bit b);  // c6  THREE ports
  logic [7:0] d;
  modport MP(input a, input w, input b, output d);
endinterface

interface if_noport;                          // c7  NO header port at all
  logic [7:0] d;
  logic       e;
  modport MP(output d, output e);
endinterface

interface if_portonly(input bit clock);       // c8  PORT ONLY, no body vars
  modport MP(input clock);
endinterface

interface if_nomp(input bit clock);           // c9  bit port, NO modport
  logic [7:0] d;
endinterface

// ---- receivers: a modport-qualified port (c1..c8) and a whole-interface port
// ---- (c9), each connected with a BARE, dot-free expression.
module rx_bit   (if_bit.MP    p); endmodule
module rx_wire  (if_wire.MP   p); endmodule
module rx_logic (if_logic.MP  p); endmodule
module rx_int   (if_int.MP    p); endmodule
module rx_reg   (if_reg.MP    p); endmodule
module rx_multi (if_multi.MP  p); endmodule
module rx_noport(if_noport.MP p); endmodule
module rx_ponly (if_portonly.MP p); endmodule
module rx_nomp  (if_nomp      p); endmodule

module top();
  bit  Clock;
  wire Wclk;
  logic Lclk;
  int  Nn;

  if_bit      c1(Clock);
  if_wire     c2(Wclk);
  if_logic    c3(Lclk);
  if_int      c4(Nn);
  if_reg      c5();
  if_multi    c6(Clock, Wclk, Clock);
  if_noport   c7();
  if_portonly c8(Clock);
  if_nomp     c9(Clock);

  rx_bit    r1(c1);
  rx_wire   r2(c2);
  rx_logic  r3(c3);
  rx_int    r4(c4);
  rx_reg    r5(c5);
  rx_multi  r6(c6);
  rx_noport r7(c7);
  rx_ponly  r8(c8);
  rx_nomp   r9(c9);
endmodule
