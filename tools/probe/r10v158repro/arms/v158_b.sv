// v158 arm B — OVERRIDE / SPECIALIZATION AXIS, in ONE database.
package Zpk;
  class parcel7;
    int n;
    static function parcel7 hatch(string s); hatch = new(); endfunction
    function string tag(); return "parcel"; endfunction
  endclass

  // default binding rejected; #(parcel7) specialization ACCEPTED
  class Gate7 #(type PP = int);
    function void step();
      if (1) begin
        PP one7;
        one7 = PP::hatch("one7");
      end
    endfunction
  endclass

  // TWO specializations of ONE class, both accepted, alongside the
  // rejected default.
  class Twin7 #(type PP = int, int W7 = 4);
    function void step();
      if (1) begin
        PP due7;
        bit [W7-1:0] mask7;
        due7 = PP::hatch("due7");
        mask7 = 0;
      end
    endfunction
  endclass

  class user7;
    Gate7#(parcel7) g7;
    Twin7#(parcel7, 8)  t7a;
    Twin7#(parcel7, 16) t7b;
    function void run();
      g7  = new();
      t7a = new();
      t7b = new();
      g7.step();
      t7a.step();
      t7b.step();
    endfunction
  endclass
endpackage

module wtop_b;
  Zpk::user7 u7;
  initial begin
    u7 = new();
    u7.run();
  end
endmodule
