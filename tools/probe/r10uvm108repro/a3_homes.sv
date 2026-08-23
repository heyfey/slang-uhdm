// r10uvm108 GRID arm 3 -- the SYMBOL HOMES an event-control operand can name,
// read from every kind of enclosing scope.  Arms 1 and 2 fixed the shape and
// the position; this one varies WHERE THE NAME LIVES and WHO IS READING IT.
package hm108_pkg;
  event pkgEvent;
  logic pkgFlag;

  class token108;
    event fired;
  endclass

  // e01 -- a PACKAGE FREE TASK reading a PACKAGE event, bare
  task automatic e01_pkgread();
    @pkgEvent;
  endtask

  // e02 -- a PACKAGE FREE TASK reading a PACKAGE variable, bare
  task automatic e02_pkgvar();
    @pkgFlag;
  endtask

  // e03 -- a PACKAGE FREE TASK reading its OWN local, dotted
  task automatic e03_ownlocal();
    token108 aa03; aa03 = new();
    @aa03.fired;
  endtask

  // e04 -- a PACKAGE FREE FUNCTION's local read by a task that CALLS it
  //        (control: a plain local in a package task, bare)
  task automatic e04_bare();
    event bb04;
    @bb04;
  endtask

  class reader108;
    event      propEv;
    token108   propTok;
    static event statEv;

    // e05 -- in-body class method reading a PACKAGE event
    task automatic e05_pkg();
      @pkgEvent;
    endtask

    // e06 -- in-body class method reading its OWN property event
    task automatic e06_prop();
      @propEv;
    endtask

    // e07 -- in-body class method reading a STATIC property event
    task automatic e07_stat();
      @statEv;
    endtask

    // e08 -- in-body class method reading a local, dotted
    task automatic e08_local();
      token108 cc08; cc08 = new();
      @cc08.fired;
    endtask

    // e09 -- in-body class method: the event expression is a CALL's result
    task automatic e09_call();
      token108 dd09; dd09 = new();
      @(dd09.fired or pkgEvent);
    endtask
  endclass
endpackage

// e10..e13 -- a $unit-scope subroutine (no package, no class)
event unitEvent108;
task automatic e10_unittask();
  event ee10;
  @ee10;
endtask
task automatic e11_unitread();
  @unitEvent108;
endtask

module hm108_top;
  import hm108_pkg::*;
  logic     modFlag;
  event     modEvent;
  token108  modTok;

  // e12 -- a module task reading a MODULE variable
  task automatic e12_modvar();
    @modFlag;
  endtask

  // e13 -- a module task reading a MODULE event
  task automatic e13_modev();
    @modEvent;
  endtask

  // e14 -- a module task reading a MODULE class handle, dotted
  task automatic e14_modtok();
    @modTok.fired;
  endtask

  // e15 -- a module initial reading a module variable
  initial @modFlag;

  // e16 -- an always block reading a module variable
  always @(modFlag) modFlag = modFlag;

  // e17 -- a module initial reading a PACKAGE event
  initial @pkgEvent;

  hm108_sub u_sub();
endmodule

module hm108_sub;
  event subEvent;
  // e18 -- an always in a CHILD instance
  always @(subEvent) ;
endmodule

interface hm108_if;
  event ifEvent;
  // e19 -- an always inside an interface
  always @(ifEvent) ;
  // e20 -- an interface task reading the interface's event
  task automatic e20_iftask();
    @ifEvent;
  endtask
endinterface

program hm108_prog;
  event progEvent;
  // e21 -- a program initial
  initial @progEvent;
endprogram
