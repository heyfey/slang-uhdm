// r10svs7 VERIFIER arm v2 — EVERY OTHER PLACE the word `new` can stand, so the
// product `{target kind} x {scope} x {Lhs shape}` has no empty cell left
// unvisited by the grid.
//
// H-cells are COVERGROUP targets (§ covergroupNewCall7's territory);
// K-cells are the MUST-ABSTAIN controls (class handle, super chain-up, shallow
// copy, dynamic array, queue) that a wrong gate would capture.
module v2;
  bit clk;

  covergroup cgp (int a = 5) @(posedge clk);
    cpa: coverpoint a;
  endgroup

  // ---- H1: module-scope DECLARATION INITIALIZER (src/ModuleEmit.cpp's arm,
  // NOT the ExprEmit arm) with a DEFAULTED formal.
  cgp h1 = new;

  // ---- H2: an ARRAY ELEMENT as the assignment target.
  cgp h2arr[2];
  initial begin
    h2arr[0] = new(1);
  end

  class holder;
    cgp hc;
    covergroup emb @(posedge clk);
      cpx: coverpoint clk;
    endgroup
    // ---- H4: an EMBEDDED covergroup instantiated in the CONSTRUCTOR (the
    // corpus shape; slang REJECTS the assignment anywhere else — measured:
    // "cannot assign to read-only variable 'emb'").
    function new();
      emb = new();
    endfunction
    // ---- H5: STATIC method context.
    static function void smk(holder o);
      o.hc = new(2);
    endfunction
  endclass

  holder hh;
  // ---- H3: through ANOTHER object's handle (not `this.`).
  initial begin
    hh.hc = new(3);
  end

  // ---- K-cells: MUST ABSTAIN ---------------------------------------------
  class base;
    int v;
    function new(int x = 4);
      v = x;
    endfunction
  endclass
  class derived extends base;
    function new();
      super.new(7);
    endfunction
  endclass

  base k1;
  base k2;
  derived k3;
  int k4[];
  int k5[$];

  initial begin
    k1 = new(9);          // K1 class handle, written arg
  end
  initial begin
    k2 = new;             // K2 class handle, defaulted formal
  end
  initial begin
    k3 = new();           // K3 derived, chains super.new
  end
  initial begin
    k4 = new[4];          // K4 dynamic array
  end
  initial begin
    k5.push_back(1);      // K5 queue method call (no `new`)
  end
endmodule
