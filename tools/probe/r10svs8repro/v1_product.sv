// r10svs8 VERIFIER ARM v1 -- THE EMPTY PRODUCT CELLS.
//
// The implementer's grid crosses {built-in} x {context} x {args} but leaves the
// RECEIVER-SHAPE axis crossed with the ARGS axis EMPTY, and never writes a
// receiver that is an ELEMENT SELECT or a task FORMAL.  Every cell here reaches
// § covergroupBuiltinCall8 (parent scope CovergroupBody, thisClass() non-null),
// so every one of them is INSIDE the new gate and none of them was measured.
//
// V1  ARRAY receiver            cva8[0].sample();      -> § deepRecvCall11 indexed segment
// V2  task FORMAL receiver      c8.sample();           receiver is a subroutine arg
// V3  DEEP receiver WITH ARGS   h8.cgi8.sample(3);     args x deep-receiver product cell
// V4  THIS receiver WITH ARGS   this.cgi8.sample(3);   args x this-rooted product cell
// V5  THREE-deep receiver       o8.h8.cgi8.sample();
// V6  built-in in a CONSTRUCTOR (last statement -- the r10svs7 R5 hazard)
// V7  get_coverage() in STATEMENT position via void'()
// V8  start()/stop() on a THIS-rooted receiver (built-in x receiver-shape)
module v1;

  int q8;

  covergroup cgm8;
    cpm8 : coverpoint q8;
  endgroup

  cgm8 cva8[2];

  initial begin
    cva8[0] = new;
    cva8[0].sample();
  end

  task tf8(cgm8 c8);
    c8.sample();
  endtask

  class inner8;
    int p8;
    covergroup cgi8 with function sample(int x8);
      cpi8 : coverpoint p8;
    endgroup
    function new();
      cgi8 = new();
    endfunction
    task v4_8();
      this.cgi8.sample(3);
    endtask
    task v8_8();
      this.cgi8.start();
    endtask
  endclass

  class outer8;
    inner8 h8;
    function new();
      h8 = new();
    endfunction
    task v3_8();
      h8.cgi8.sample(3);
    endtask
  endclass

  class outer2_8;
    outer8 o8;
    function new();
      o8 = new();
    endfunction
    task v5_8();
      o8.h8.cgi8.sample(3);
    endtask
  endclass

  class ctor8;
    int r8;
    real cv8;
    covergroup cgk8;
      cpk8 : coverpoint r8;
    endgroup
    function new();
      cgk8 = new();
    endfunction
    task v6_8();
      cgk8.sample();
    endtask
    task v7_8();
      void'(cgk8.get_coverage());
    endtask
  endclass

endmodule
