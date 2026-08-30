// r10uvm161 arm B — WHAT MUST NOT MOVE.  Every referent kind an in-body class
// method can name, read TWICE from the same method: once from an `if`
// CONDITION (the window our emitter ALREADY opens, so its cells are the
// pristine-correct control) and once from an IMMEDIATE ASSERTION CONDITION
// (the window this pass opens).  If golden's answer is the SAME in both
// columns for every referent kind, then making the two positions take the same
// code path cannot move a cell golden leaves bare — and if it is NOT the same,
// this arm is the counter-witness that stops the pass.
//
// The two columns are deliberately spelled with DIFFERENT names, numbers and
// literals so an arm cannot confirm itself.
package pkgb161;

  typedef enum int { ORIOLE161 = 3, KESTREL161 = 5 } birds161_e;

  int pkgvar161 = 7;
  parameter int PKGPAR161 = 9;

  class base161;
    int inherited161;
  endclass

  class notmove161 extends base161;
    int prop161;
    static int sprop161;
    const int cprop161 = 11;
    base161 handle161;
    int arr161[4];
    int que161[$];
    birds161_e bird161;
    localparam int CLSPAR161 = 13;

    function void probe161(int gargoyle161);
      int hobnail161;
      static int trivet161;
      base161 lintel161;
      birds161_e finch161;

      // ---------- COLUMN 1: the `if` CONDITION (already a window) ----------
      if (hobnail161 == 21) prop161 = 22;                 // plain local
      if (trivet161 == 23) prop161 = 24;                  // STATIC local
      if (gargoyle161 == 25) prop161 = 26;                // formal
      if (prop161 == 27) hobnail161 = 28;                 // class property
      if (sprop161 == 29) hobnail161 = 30;                // STATIC property
      if (cprop161 == 31) hobnail161 = 32;                // CONST property
      if (inherited161 == 33) hobnail161 = 34;            // INHERITED property
      if (handle161 == null) hobnail161 = 35;             // class-handle property
      if (lintel161 == null) hobnail161 = 36;             // class-handle local
      if (arr161[0] == 37) hobnail161 = 38;               // property array element
      if (que161.size() == 39) hobnail161 = 40;           // queue method call
      if (bird161 == ORIOLE161) hobnail161 = 41;          // enum property + enum const
      if (finch161 == KESTREL161) hobnail161 = 42;        // enum local + enum const
      if (CLSPAR161 == 43) hobnail161 = 44;               // class localparam
      if (PKGPAR161 == 45) hobnail161 = 46;               // package parameter
      if (pkgvar161 == 47) hobnail161 = 48;               // package variable
      if (this.prop161 == 49) hobnail161 = 50;            // this-qualified property
      if ($bits(hobnail161) == 51) hobnail161 = 52;       // SYSTEM call argument

      // ---------- COLUMN 2: the ASSERTION CONDITION ----------
      assert (hobnail161 != 61);
      assert (trivet161 != 62);
      assert (gargoyle161 != 63);
      assert (prop161 != 64);
      assert (sprop161 != 65);
      assert (cprop161 != 66);
      assert (inherited161 != 67);
      assert (handle161 != null);
      assert (lintel161 != null);
      assert (arr161[1] != 68);
      assert (que161.size() != 69);
      assert (bird161 != KESTREL161);
      assert (finch161 != ORIOLE161);
      assert (CLSPAR161 != 70);
      assert (PKGPAR161 != 71);
      assert (pkgvar161 != 72);
      assert (this.prop161 != 73);
      assert ($bits(hobnail161) != 74);
    endfunction
  endclass

endpackage
