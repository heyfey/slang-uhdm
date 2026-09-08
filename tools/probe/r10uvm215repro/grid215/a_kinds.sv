// r10uvm215 GRID ARM A — THE LAW: which MODPORT ITEM KIND mints the object.
// One interface per cell, each with exactly ONE modport, so a dropped modport
// cannot be hidden by a surviving sibling.  Every interface is INSTANTIATED in
// the top module, so both the def listing and the elaborated instance carry it.
//
// a1 simple ports only          -> the POSITIVE CONTROL: the object must exist
// a2 clocking item only         -> the CORPUS SHAPE (SeqDriver's mon_mp)
// a3 import task only
// a4 export function only
// a5 clocking + simple mixed
// a6 two clocking items only
// a7 explicit expression port only (`.P(x)`)
// a8 import tf + clocking, no simple port

interface a1_if;
  logic clk;
  logic d;
  modport mp (input clk, output d);
endinterface

interface a2_if;
  logic clk;
  logic frame;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mp (clocking cb);
endinterface

interface a3_if;
  logic clk;
  task automatic t3(input logic v);
  endtask
  modport mp (import t3);
endinterface

interface a4_if;
  logic clk;
  function void f4(input logic v);
  endfunction
  modport mp (export f4);
endinterface

interface a5_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mp (clocking cb, input d);
endinterface

interface a6_if;
  logic clk;
  logic frame;
  logic other;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  clocking cb2 @(negedge clk);
    inout other;
  endclocking
  modport mp (clocking cb, clocking cb2);
endinterface

interface a7_if;
  logic clk;
  logic [3:0] r;
  modport mp (input .P(r[3:0]));
endinterface

interface a8_if;
  logic clk;
  logic frame;
  task automatic t8(input logic v);
  endtask
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mp (import t8, clocking cb);
endinterface

module top;
  a1_if i1();
  a2_if i2();
  a3_if i3();
  a4_if i4();
  a5_if i5();
  a6_if i6();
  a7_if i7();
  a8_if i8();
endmodule
