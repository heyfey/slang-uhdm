// v125 arm V2 — every call-arg FACE against the same callee family:
// input / output / inout / ref / const ref, matching AND converting actuals.
package Face_Pkg;
  typedef logic [95:0] Huge;
  typedef logic [11:0] Tiny;

  function automatic int fIn   (input  Huge a);            return int'(a[3:0]); endfunction
  function automatic int fOut  (output Huge a);  a = 96'd5; return 1;           endfunction
  function automatic int fInout(inout  Huge a);  a = a + 1; return 2;           endfunction
  function automatic int fRef  (ref    Huge a);  a = a + 3; return 4;           endfunction
  function automatic int fCref (const ref Huge a);         return int'(a[1:0]); endfunction

  class Face_Holder;
    int rc;
    Huge hh;
    Tiny tt;
    function void exercise();
      Huge  bigLocal;
      Tiny  smallLocal;
      int   plainInt;
      rc = fIn(smallLocal);        // input, converting  (never an lvalue arg)
      rc = fIn(bigLocal);          // input, matching
      rc = fOut(bigLocal);         // output, matching   -> bare EmptyArgument
      rc = fOut(smallLocal);       // output, converting -> Conversion(Empty)
      rc = fOut(plainInt);         // output, int actual
      rc = fInout(bigLocal);       // inout, matching
      rc = fInout(smallLocal);     // inout, converting
      rc = fRef(bigLocal);         // ref  (must be exact type)
      rc = fCref(bigLocal);        // const ref
      rc = fOut(hh);               // output onto a class property, matching
      rc = fOut(tt);               // output onto a class property, converting
      rc = fOut(this.tt);          // output onto an explicitly qualified property
    endfunction
  endclass
endpackage
