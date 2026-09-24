// r10svs7 ARM a2 -- ARGUMENTS on a covergroup `new`.
//
// A covergroup may declare FORMALS (`covergroup cg (int a, string s);`), and the
// handle is then constructed `cg = new(1, "x")`.  slang BINDS these
// (NewCovergroupExpression::fromSyntax runs CallExpression::bindArgs against
// CovergroupType::getArguments()), so the actuals arrive as ordinary bound
// Expressions -- unlike § invalidNewCallFromSyntax55, where nothing was bound
// and the arguments had to be read off the SYNTAX.
//
// ONE STATEMENT PER CONSTRUCTOR (see a1's header for why).
//
// CELLS
//   D1  litargs   -- `cg = new(3)`             literal actual
//   D2  refargs   -- `cg = new(w)`             a class-property reference actual
//   D3  twoargs   -- `cg = new(3, w)`          two actuals, mixed
//   D4  clsargs   -- a CLASS handle `= new(3)` IN-LAW control (bound NewClass)
module a2;
  class litargs;
    int p;
    covergroup cgd1 (int a);
      cpd1 : coverpoint p;
    endgroup
    function new();
      cgd1 = new(3);              // D1
    endfunction : new
  endclass

  class refargs;
    int p;
    int w;
    covergroup cgd2 (int a);
      cpd2 : coverpoint p;
    endgroup
    function new();
      cgd2 = new(w);              // D2
    endfunction : new
  endclass

  class twoargs;
    int p;
    int w;
    covergroup cgd3 (int a, int b);
      cpd3 : coverpoint p;
    endgroup
    function new();
      cgd3 = new(3, w);           // D3
    endfunction : new
  endclass

  class ctor_with_arg;
    int v;
    function new(int a); v = a; endfunction
  endclass

  class clsargs;
    ctor_with_arg h;
    function new();
      h = new(3);                 // D4 -- IN-LAW control
    endfunction : new
  endclass
endmodule
