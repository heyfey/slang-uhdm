// r10v172 arm 5 — CHAIN SHAPE and ARGUMENTS.  Chains of two, three, four and
// five components; a subscript on the FIRST, SECOND and LAST component; named
// arguments; an empty argument list; a literal argument; a call argument; a
// void function; recursion; the base naming the enclosing TASK; `this.` and
// `super.` roots; and a statement call with NO enclosing subroutine.
// MEASUREMENT ONLY.
package pv5172;
  function int five172(); return 5; endfunction
  function int six172();  return 6; endfunction

  class Leaf5172;
    string q172[$];
    int    n172;
    function void takes2172(int a, int b); n172 = a + b; endfunction
    function void takes1172(int a); n172 = a; endfunction
    function void none172(); endfunction
  endclass

  class Mid5172;
    Leaf5172 lf172;
    Leaf5172 larr172[4];
    function new(); lf172 = new(); endfunction
    function void mtakes1172(int a); endfunction
  endclass

  class Deep5172;
    Mid5172 md172;
    function new(); md172 = new(); endfunction
  endclass

  class Base5172;
    function void bfn172(); endfunction
  endclass

  class Probe5172 extends Base5172;
    Deep5172 five172;          // the collapsing spelling as a class PROPERTY
    Leaf5172 six172;
    int      loc172;

    function void shapes172();
      Leaf5172 shapes172;      // v5_13 the base names THIS function
      shapes172 = new();
      // v5_01 TWO components, no arguments
      six172.none172();
      // v5_02 TWO components, TWO written arguments (both must survive)
      six172.takes2172(loc172, 3);
      // v5_03 TWO components, ONE literal argument
      six172.takes1172(7);
      // v5_04 TWO components, NAMED arguments
      six172.takes2172(.a(1), .b(2));
      // v5_05 TWO components, a CALL as the argument
      six172.takes1172(pv5172::five172());
      // v5_06 THREE components WITH an argument (it must be DROPPED)
      five172.md172.mtakes1172(3);
      // v5_07 FOUR components
      five172.md172.lf172.takes1172(4);
      // v5_08 FIVE components
      five172.md172.lf172.q172.push_back("v5_08");
      // v5_09 a subscript on the SECOND component (the declined shape)
      five172.md172.larr172[1].takes1172(5);
      // v5_10 a subscript-free TWO-name chain on a queue
      six172.q172.push_back("v5_10");
      // v5_11 `this.`-rooted — a different Surelog road
      this.six172.q172.push_back("v5_11");
      // v5_12 `super.`-rooted
      super.bfn172();
      // v5_13 the base names THIS function, chain of three
      shapes172.q172.push_back("v5_13");
    endfunction

    // v5_14 the base names the ENCLOSING TASK
    task tselfname172();
      Leaf5172 tselfname172;
      tselfname172 = new(); tselfname172.q172.push_back("v5_14");
    endtask

    // v5_15 a VOID function whose name is the base
    function void voidfn172();
      Leaf5172 voidfn172;
      voidfn172 = new(); voidfn172.q172.push_back("v5_15");
    endfunction
  endclass
endpackage

module topv5172;
  import pv5172::*;
  function int modfn172(); return 1; endfunction

  Leaf5172 mvar172;
  pv5172::Probe5172 p172;

  // v5_16 — a statement call with NO enclosing subroutine (an initial body),
  // the base spelling naming the module's own function
  initial begin
    Leaf5172 modfn172;
    modfn172 = new();
    modfn172.q172.push_back("v5_16");
    mvar172 = new();
    p172 = new();
    p172.shapes172();
    p172.tselfname172();
    p172.voidfn172();
  end

  // v5_17 — the same face inside an always_comb body
  always_comb begin
    Leaf5172 modfn172;
    modfn172 = new();
    modfn172.q172.push_back("v5_17");
  end
endmodule
