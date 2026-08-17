// r10buvm8 v2 — THE FENCE CELLS.  v1 established that golden stamps a
// ref_typespec on a func_call ARGUMENT only in the ELABORATED listing, only for
// a call reached with Reduce::Yes (the RETURN expression), and only when the
// call SURVIVES the constant-function fold.  v2 attacks the boundary:
//   * an SV function with a body that CANNOT fold      (b1)
//   * case / while / for / ternary / nested-call contexts (b2..b6)
//   * scopes: class method, module function, $unit function (b7..b9)
//   * formal types: typedef'd, unpacked-array, output/inout, defaulted (b10..b13)
//   * argument shapes reduceExpr declines: part_select, hier_path, real (b14)
//   * arg-by-NAME (b15)

package q8;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  typedef string strn_t;

  import "DPI-C" context function int  dpi_i (string re, string str);
  import "DPI-C"         function int  dpi_td (strn_t a, st_t b);
  import "DPI-C"         function int  dpi_out (string a, output int b);
  import "DPI-C"         function int  dpi_def (string a);
  import "DPI-C"         function real dpi_r (real a);

  int gvar;

  // b1: SV function whose body cannot fold (reads a package variable)
  function int nf (string re, string str); return gvar; endfunction
  function int fold (string re, string str); return 7; endfunction

  function bit b1 (string s, string t);
    return (nf(s, t) == 0);                 // b1a  non-foldable SV callee
  endfunction
  function bit b1b (string s, string t);
    return (fold(s, t) == 0);               // b1b  foldable SV callee
  endfunction

  // b2: case statement / case item
  function int b2 (string s, string t);
    case (dpi_i(s, t))                      // b2a  case condition
      dpi_i(s, t): return 1;                // b2b  case item expression
      default: return 0;
    endcase
  endfunction

  // b3: while / for / do-while conditions
  function int b3 (string s, string t);
    int n; n = 0;
    while (dpi_i(s, t) == 0) n++;           // b3a
    for (int i = 0; i < dpi_i(s, t); i++) n++;   // b3b
    do n++; while (dpi_i(s, t) != 0);       // b3c
    return n;
  endfunction

  // b4: ternary in a return
  function int b4 (string s, string t);
    return (dpi_i(s, t) == 0) ? 1 : 2;      // b4a
  endfunction

  // b5: NESTED calls in a return
  function string idn (string g); return g; endfunction
  function int b5 (string s, string t);
    return dpi_i(idn(s), t);                // b5a  inner SV call as DPI arg
  endfunction
  function int b5b (string s, string t);
    return dpi_i(s, t) + dpi_i(t, s);       // b5b  two DPI calls in one return
  endfunction

  // b6: DPI call in a return inside nested control flow
  function int b6 (string s, string t);
    if (s == "x") begin
      for (int i = 0; i < 2; i++) begin
        return (dpi_i(s, t) == 0);          // b6a  deep return
      end
    end
    return 0;
  endfunction

  // b7: class method
  class kls;
    function int m (string s, string t);
      return (dpi_i(s, t) == 0);            // b7a  return inside a class method
    endfunction
  endclass

  // b10..b13: formal TYPES
  function int b10 (string s, st_t v);
    return (dpi_td(s, v) == 0);             // b10a typedef'd string + struct formals
  endfunction
  function int b11 (string s);
    int o;
    return (dpi_out(s, o) == 0);            // b11a output formal
  endfunction
  function int b12 (string s);
    return (dpi_def(s) == 0);               // b12a single formal
  endfunction
  function real b13 (real x);
    return dpi_r(x);                        // b13a real formal
  endfunction

  // b14: argument shapes
  function int b14 (string s, string t);
    st_t v; logic [7:0] w; string arr [2]; kls k;
    k = new(); w = 8'h0; v = '{default:0};
    return (dpi_i(arr[0], t) == 0)          // b14a unpacked-array element
        || (dpi_i(s, arr[1]) == 0)          // b14b second unpacked element
        || (dpi_td(s, v) == 0)              // b14c struct var
        || (dpi_i(k.m(s,t) == 0 ? s : t, t) == 0); // b14d ternary-with-method arg
  endfunction

  // b15: argument by NAME
  function int b15 (string s, string t);
    return (dpi_i(.re(s), .str(t)) == 0);   // b15a named args
  endfunction

endpackage

// b8: a function in a MODULE
module modq8;
  import "DPI-C" function int mdpi (string a);
  function int b8 (string s);
    return (mdpi(s) == 0);                  // b8a module-scope DPI in a return
  endfunction
  int r;
  initial r = b8("z");
endmodule
