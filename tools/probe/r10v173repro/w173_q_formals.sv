// r10v173 arm Q — THE EDGE FACES OF THE FORMAL: string / int / packed vector /
// real / class handle / typedef'd, and value vs ref vs output vs inout, every
// one called from the package's DEF listing in BOTH spellings.  The brief's
// (refuted) framing was a typespec hung on a string formal's actual, so the
// string face is present twice.
package rushlight_pkg;

  typedef logic [11:0] dozen_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } nibblepair_t;

  class Taper;
    int wick;
    function new(int w); wick = w; endfunction
  endclass

  function automatic int takesString(string s);
    return s.len();
  endfunction

  function automatic int takesInt(int v);
    return v + 1;
  endfunction

  function automatic int takesVector(logic [7:0] b);
    return int'(b) + 2;
  endfunction

  function automatic int takesReal(real r);
    return int'(r) + 3;
  endfunction

  function automatic int takesHandle(Taper t);
    return (t == null) ? 0 : t.wick;
  endfunction

  function automatic int takesTypedef(dozen_t d, nibblepair_t np);
    return int'(d) + int'(np.hi);
  endfunction

  function automatic void takesRef(ref int v);
    v = v + 4;
  endfunction

  function automatic void takesOut(input int a, output int b);
    b = a + 5;
  endfunction

  function automatic void takesInout(inout int c);
    c = c + 6;
  endfunction

  // ---- the callers, all inside the package's DEF listing ----
  function automatic int bareEveryFace(string s, logic [7:0] b, real r, Taper t,
                                       dozen_t d, nibblepair_t np);
    int acc;
    acc = takesString(s) + takesInt(7) + takesVector(b) + takesReal(r)
        + takesHandle(t) + takesTypedef(d, np);
    return acc;
  endfunction

  function automatic int qualEveryFace(string s, logic [7:0] b, real r, Taper t,
                                       dozen_t d, nibblepair_t np);
    int acc;
    acc = rushlight_pkg::takesString(s) + rushlight_pkg::takesInt(7)
        + rushlight_pkg::takesVector(b) + rushlight_pkg::takesReal(r)
        + rushlight_pkg::takesHandle(t) + rushlight_pkg::takesTypedef(d, np);
    return acc;
  endfunction

  function automatic int bareDirections(int seed);
    int m, n, p;
    m = seed; n = 0; p = seed;
    takesRef(m);
    takesOut(seed, n);
    takesInout(p);
    return m + n + p;
  endfunction

  function automatic int qualDirections(int seed);
    int m, n, p;
    m = seed; n = 0; p = seed;
    rushlight_pkg::takesRef(m);
    rushlight_pkg::takesOut(seed, n);
    rushlight_pkg::takesInout(p);
    return m + n + p;
  endfunction

  // The SAME string actual, bare and qualified, in ONE expression.
  function automatic int mixedString(string s);
    return takesString(s) + rushlight_pkg::takesString(s);
  endfunction

endpackage

module rushlight_top (output int y1, output int y2, output int y3);
  import rushlight_pkg::*;
  Taper tp;
  initial tp = new(21);
  assign y1 = bareEveryFace("candle", 8'hA5, 2.5, null, 12'd9, '{4'h1, 4'h2});
  assign y2 = qualDirections(3) + rushlight_pkg::bareDirections(4);
  assign y3 = mixedString("ember");
endmodule
