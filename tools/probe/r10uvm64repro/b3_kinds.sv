// r10uvm64 arm b3 — THE VAR-KIND AND INITIALISER SPREAD, in the condition
// window, all inside ONE in-body class method at control depth 1.
//
// The brief's measurement list asked for (a) a local with a CALL initialiser
// inside `else begin`, (b) the same local with NO initialiser, (c) an
// initialiser that is not a call, (f) the var KIND spread, (g) where golden
// PARENTS the local and (h) whether golden emits the initialiser as vpiExpr and
// in what shape.  Those items were written on the assumption that we DROP the
// variable.  WE DO NOT (README §1.1) — so they are measured here anyway, both
// because a brief item is answered and not waved away, and because "does the
// vpiActual edge depend on the declaration's shape" is a real gate axis.
//
//   d<NN>_  the KIND spread
//   e<NN>_  the INITIALISER spread
//   g<NN>_  the block SHAPE spread (if-begin / else-begin / bare begin)

class b3c;
  int prop;

  function automatic int fkinds(input int farg);
    int r = 0;
    if (farg == 0) begin
      int      d01_int      = 1;
      integer  d02_integer  = 2;
      logic    d03_logic    = 1'b1;
      bit      d04_bit      = 1'b0;
      byte     d05_byte     = 8'd3;
      string   d06_string   = "s";
      real     d07_real     = 1.0;
      b3c      d08_handle   = null;
      logic [7:0] d09_vec   = 8'd4;
      if (d01_int     == 3) r = 1;
      if (d02_integer == 3) r = 2;
      if (d03_logic   == 1) r = 3;
      if (d04_bit     == 1) r = 4;
      if (d05_byte    == 3) r = 5;
      if (d06_string  == "x") r = 6;
      if (d07_real    > 0.5) r = 7;
      if (d08_handle  == null) r = 8;
      if (d09_vec     == 8'd4) r = 9;
    end
    return r;
  endfunction

  function automatic int finit(input int farg);
    int r = 0;
    if (farg == 0) begin
      int e01_none;                      // (b) NO initialiser
      int e02_lit  = 7;                  // (c) initialiser, not a call
      int e03_call = getid();            // (a) CALL initialiser, the witness
      int e04_expr = 1 + 2;              // initialiser is an operation
      if (e01_none  == 1) r = 1;
      if (e02_lit   == 2) r = 2;
      if (e03_call  == 3) r = 3;
      if (e04_expr  == 4) r = 4;
    end
    return r;
  endfunction

  function automatic int fshape(input int farg);
    int r = 0;
    if (farg == 0) begin                 // IF-begin arm
      int g01_ifbeg = 1;
      if (g01_ifbeg == 2) r = 1;
    end
    else begin                           // ELSE-begin arm, the witness shape
      int g02_elsbeg = 1;
      if (g02_elsbeg == 2) r = 2;
    end
    begin                                // BARE begin at depth 0
      int g03_bare = 1;
      if (g03_bare == 2) r = 3;
    end
    if (farg == 1) begin : gnmd          // NAMED begin at depth 1
      int g04_named = 1;
      if (g04_named == 2) r = 4;
    end
    return r;
  endfunction

  function automatic int getid();
    return 42;
  endfunction
endclass

module b3_top;
  b3c h;
  int r;
  initial begin
    h = new();
    r = h.fkinds(0);
    r = h.finit(0);
    r = h.fshape(0);
  end
endmodule
