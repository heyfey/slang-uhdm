// r10svs8 ARM a4 -- CONTEXT.  Is the law class-scoped, or is it a property of
// the CALL regardless of where it is written?
//
// F1  module INITIAL block, MODULE-scope covergroup instance
// F2  module ALWAYS block, same instance
// F3  a MODULE-scope task
// F4  `this.<cg>.sample()` -- explicit this, in a class task
// F5  a covergroup handle reached through ANOTHER class handle:
//     `h8.cg8.sample()` -- a TWO-dot receiver, which is the shape that decides
//     whether the receiver text is a single ref_obj or a hier_path
// F6  ABSTAIN control -- a plain (non-covergroup) module task call
module a4;

  int q8;

  covergroup cgm8;
    cpm8 : coverpoint q8;
  endgroup

  cgm8 cm8 = new;

  initial begin
    cm8.sample();
  end

  always @(q8) begin
    cm8.sample();
  end

  task mtask8();
    cm8.sample();
  endtask

  task plain8();
    q8 = 1;
  endtask

  task f6_8();
    plain8();
  endtask

  class inner8;
    int p8;
    covergroup cgi8;
      cpi8 : coverpoint p8;
    endgroup
    function new();
      cgi8 = new();
    endfunction
    task f4_8();
      this.cgi8.sample();
    endtask
  endclass

  class outer8;
    inner8 h8;
    function new();
      h8 = new();
    endfunction
    task f5_8();
      h8.cgi8.sample();
    endtask
  endclass

endmodule
