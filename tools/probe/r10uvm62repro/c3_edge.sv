// r10uvm62 arm c3 — THE OVER-FIRE / UNDER-FIRE TRAP arm.
//
// c1 established that a written `endclass : <name>` is the whole discriminator
// in the ordinary scopes.  This arm attacks the same rule from the awkward
// directions: containers that are NOT a package/module/unit, class SHAPES that
// carry extra syntax (interface class, implements, final, extern constraint),
// and the join-flavour axis for named_fork — plus the uvm_objection shape, a
// LABELLED FORK INSIDE A CLASS TASK, which is where the corpus residue lives.

package q;

  // interface class — `endclass : <name>` on a NON-object class
  interface class IC;
    pure virtual function int f();
  endclass : IC

  interface class IC_bare;
    pure virtual function int g();
  endclass

  // a class that IMPLEMENTS an interface class, labelled
  class Impl implements IC;
    virtual function int f(); return 1; endfunction
  endclass : Impl

  // labelled class with an EXTERN CONSTRAINT and a rand member
  class WithCon;
    rand int r;
    extern constraint c1;
  endclass : WithCon

  constraint WithCon::c1 { r > 0; }

  // labelled class whose method holds the uvm_objection FORK shape
  class Forker;
    task run();
      fork : guard
        automatic int k = 1;
        begin : inner
          k = k + 1;
        end : inner
      join_none : guard
    endtask
  endclass : Forker

  // join / join_any flavours, labelled and bare
  class Joiner;
    task t_all();
      fork : f_all
        #1;
      join : f_all
    endtask
    task t_any();
      fork : f_any
        #1;
      join_any : f_any
    endtask
    task t_none_bare();
      fork : f_bare
        #1;
      join_none
    endtask
  endclass : Joiner

endpackage : q

interface iface_host;
  // class declared INSIDE an interface, labelled
  class InIface;
    int a;
  endclass : InIface
  class InIface_bare;
    int a;
  endclass
endinterface : iface_host

program prog_host;
  // class declared INSIDE a program, labelled
  class InProg;
    int b;
  endclass : InProg
  class InProg_bare;
    int b;
  endclass
  initial begin end
endprogram : prog_host

module top_c3;
  iface_host ih();
  q::Forker fk;
  q::Joiner jn;
  q::Impl im;
  q::WithCon wc;
  initial begin
    fk = new(); jn = new(); im = new(); wc = new();
  end
endmodule : top_c3
