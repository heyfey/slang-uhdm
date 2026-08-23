// r10uvm108 GRID arm 1 -- EVENT-CONTROL OPERAND SHAPES, all inside IN-BODY
// class methods of a package class (the corpus shape: uvm_config_db is a
// package class and wait_modified is written inside the class body).
// Every cell has its OWN identifier spelling so no two cells can confirm each
// other by name collision.
package sh108_pkg;

  class waiter108;
    event trigger;
    event backup;
  endclass

  class holder108;
    waiter108 slots[3];
    function new(); foreach (slots[i]) slots[i] = new(); endfunction
  endclass

  event pkg_ev108;

  class shapes108;
    waiter108 propHandle;
    event      propEvent;
    static waiter108 statHandle;
    bit        propBit;

    // c01 -- the corpus shape: parens-less DOTTED path over a task local
    task automatic c01_dotted();
      waiter108 kk01;
      kk01 = new();
      @kk01.trigger;
    endtask

    // c02 -- the same path PARENTHESISED
    task automatic c02_paren();
      waiter108 zz02;
      zz02 = new();
      @(zz02.trigger);
    endtask

    // c03 -- a THREE-deep parens-less path (`.triggered` on the event)
    task automatic c03_deep();
      waiter108 mm03;
      mm03 = new();
      @mm03.trigger.triggered;
    endtask

    // c04 -- the same read inside a wait_stmt instead
    task automatic c04_wait();
      waiter108 rr04;
      rr04 = new();
      wait (rr04.trigger.triggered);
    endtask

    // c05 -- a BARE local event (uvm_sequence_base::wait_for_relevant's shape)
    task automatic c05_bare();
      event ev05;
      @ev05;
    endtask

    // c06 -- the same, parenthesised
    task automatic c06_bareparen();
      event ev06;
      @(ev06);
    endtask

    // c07 -- an EDGE over a local bit
    task automatic c07_edge();
      bit sig07;
      @(posedge sig07);
    endtask

    // c08 -- an event LIST of two locals
    task automatic c08_or();
      event first08, second08;
      @(first08 or second08);
    endtask

    // c09 -- a list mixing a dotted handle read with a bare local
    task automatic c09_mixed();
      waiter108 hh09;
      event      ev09;
      hh09 = new();
      @(hh09.trigger or ev09);
    endtask

    // c10 -- `this.` prefixed CLASS PROPERTY event
    task automatic c10_this();
      @this.propEvent;
    endtask

    // c11 -- an INDEXED path through a task-local handle
    task automatic c11_index();
      holder108 bag11;
      bag11 = new();
      @bag11.slots[0].trigger;
    endtask

    // c12 -- a PACKAGE-scope event, written unqualified
    task automatic c12_pkgev();
      @pkg_ev108;
    endtask

    // c13 -- `iff` over a dotted handle read
    task automatic c13_iff();
      waiter108 ww13;
      bit        gate13;
      ww13 = new();
      @(ww13.trigger iff gate13);
    endtask

    // c14 -- a plain (non-event) local VARIABLE as the event expression
    task automatic c14_var();
      logic lv14;
      @lv14;
    endtask

    // c15 -- the same, parenthesised
    task automatic c15_varparen();
      logic lv15;
      @(lv15);
    endtask

    // c16 -- the CLASS PROPERTY handle, dotted (uvm_event_base's `@m_event`
    //       shape but one level deeper)
    task automatic c16_prop();
      @propHandle.trigger;
    endtask

    // c17 -- a BARE class-property event (uvm_event_base::wait_trigger)
    task automatic c17_propbare();
      @propEvent;
    endtask

    // c18 -- a STATIC class property handle, dotted
    task automatic c18_static();
      @statHandle.trigger;
    endtask

    // c19 -- a FORMAL argument handle, dotted
    task automatic c19_formal(waiter108 arg19);
      @arg19.trigger;
    endtask

    // c20 -- a FORMAL event, bare
    task automatic c20_formalev(event arg20);
      @arg20;
    endtask
  endclass
endpackage

module top108;
  import sh108_pkg::*;
  initial begin
    shapes108 s108;
    s108 = new();
  end
endmodule
