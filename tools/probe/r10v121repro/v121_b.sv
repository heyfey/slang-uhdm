// r10uvm121 VERIFIER arm B — CONTEXTS the implementer's grid never entered:
// a class declared INSIDE A MODULE (not a package), a VIRTUAL class, a
// PARAMETERIZED class, a NESTED class, a static method beside a non-static
// one, an automatic function, and the same law under a class in a $unit scope.
// Vocabulary unrelated to arm a / arm A.
module lantern_top;

  virtual class Shade;
     int lumen;
     function new(int cd = 1); lumen = cd; endfunction
     pure virtual function void dim();
  endclass

  class Pane extends Shade;             // CONCRETE subclass, the assignable type
     function new(int cd = 1); super.new(cd); endfunction
     virtual function void dim(); lumen = 0; endfunction
  endclass

  class Globe #(int PANE = 2) extends Shade;
     Pane gasket;
     Pane mantle;
     Pane wick;
     Pane collar[];
     int pane_ct;
     // OUT-OF-BODY declaration inside a module scope
     extern function new(int cd);
     extern virtual function void dim();
     extern static function int census();
     class Bracket;                       // NESTED class
        Pane pin;
        function new();
           this.pin = new(3);             // B01 nested class ctor, this.
        endfunction
     endclass
     Bracket brace;
  endclass

  function Globe::new(int cd);
     super.new(cd);
     this.gasket = new(cd);               // B02 param class ctor, this.
     this.collar = new[PANE];             // B03 param class ctor, new[param]
     pane_ct     = PANE;
     this.brace  = new;                   // B04 nested-class handle, this.
  endfunction

  function void Globe::dim();
     if (pane_ct > 0)
        this.mantle = new;                // B05 virtual method, sole if branch
     while (pane_ct == 4)
        this.wick = new(2);               // B06 virtual method, while body
  endfunction

  function int Globe::census();
     return PANE;                         // static, no `this` possible
  endfunction

  Globe #(3) g3;
  Globe #(5) g5;
  initial begin
     g3 = new(1);
     g5 = new(2);
     g3.dim();
  end
endmodule
