// r10svs8 ARM a1 -- THE WITNESS.
//
// Reproduces third_party/tests/SVSwitch/Coverage.sv:36 exactly: an EMBEDDED
// covergroup, constructed in `function new`, and `<cg>.sample();` written as a
// STATEMENT in a class TASK whose own name is also `sample` in the corpus.
//
// HAZARD carried from r10svs7 README §2.1: Surelog keeps only the LAST
// statement of a class CONSTRUCTOR body.  Every `new` here therefore has
// EXACTLY ONE statement, and every multi-statement body is a task/function.
//
// C1  the witness                 cg8.sample();          in a class TASK
// C2  same call in a FUNCTION     cg8.sample();          in a class FUNCTION
// C3  IN-LAW control              p8.touch();            USER method, class handle
// C4  IN-LAW control              this.touch2();         USER method, implicit recv
// C5  the corpus's own collision  a class task NAMED `sample` that calls the
//                                 covergroup's built-in `sample` -- the exact
//                                 name shadowing SVSwitch writes.
module a1;

  class pkt8;
    int len;
    function void touch();
      len = 1;
    endfunction
  endclass

  class cov8;
    pkt8 p8;
    int  q8;

    covergroup cg8;
      cpq8 : coverpoint q8;
    endgroup

    function new();
      cg8 = new();
    endfunction

    task samp8();
      cg8.sample();
    endtask

    function void fsamp8();
      cg8.sample();
    endfunction

    task inlaw8();
      p8.touch();
    endtask

    function void touch2();
      q8 = 2;
    endfunction

    task inlaw8b();
      this.touch2();
    endtask

    task sample(pkt8 pin);
      this.p8 = pin;
      cg8.sample();
    endtask
  endclass

endmodule
