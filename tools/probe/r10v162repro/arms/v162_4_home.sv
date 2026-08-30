// r10v162 arm 4 — WHERE THE REJECTED CONCATENATION LIVES, and how many
// specializations are in the database beside the default one.
//
//   a generic class DEFAULT specialization        (H1)
//   a specialization whose argument is a CLASS type (H2 — the type DOES carry
//     the method, so slang binds and nothing is rejected: the control that the
//     law does not fire where binding succeeds)
//   an OUT-OF-BODY method                          (H3)
//   a STATIC method                                (H4)
//   a TASK                                         (H5)
//   a package FUNCTION (not a class member at all) (H6 — a bad concat cannot
//     arise from a type parameter here; the control is that it is untouched)
//   a NON-GENERIC class                            (H7 — control)
//   ONE, TWO and THREE explicit specializations beside the default (I1..I3)
//
// MEASUREMENT ONLY.
package Home4_pkg;

  class Carrier4;
    function new(string nm = "c"); endfunction
    function string mark();  return "m"; endfunction
    function string reach(); return "r"; endfunction
  endclass

  // H1/H3/H4/H5 all in one generic class
  class Lodge4 #(type SLOT = int);
    static string pile = "";
    string    hold;
    Carrier4  car;
    SLOT      sl;

    // H1 — an ordinary in-body method of the DEFAULT specialization
    function void h1(); pile = {"{", hold=="" ? "a" : car.mark(), "}", sl.miss()}; endfunction
    // H3 — declared here, defined OUT OF BODY below
    extern function void h3();
    // H4 — a STATIC method
    static function void h4(); pile = {"{", {2{"s"}}, "}"}; endfunction
    // H5 — a TASK
    task h5(); pile = {"{", hold=="" ? "a" : car.mark(), "}", sl.miss()}; endtask
    // a static method that DOES hold the bad shape (a static local of the
    // type parameter, so the call is silently unbindable there too)
    static function void h4b(); SLOT q; pile = {"{", "a"=="" ? "p" : "q", "}", q.miss()}; endfunction
  endclass

  function void Lodge4::h3();
    pile = {"{", hold=="" ? "a" : car.mark(), "}", sl.miss()};
  endfunction

  // H2 — an explicit specialization whose argument DOES carry the method
  class Reached4;
    function string miss(); return "R"; endfunction
    function string mark(); return "M"; endfunction
  endclass

  // H6 — a package function
  function string h6(string a, string b);
    return {"{", a=="" ? "p" : b, "}"};
  endfunction

  // H7 — a NON-generic class control
  class Plain4;
    string hold;
    Carrier4 car;
    static string pile = "";
    function void h7(); pile = {"{", hold=="" ? "a" : car.mark(), "}"}; endfunction
  endclass

  // two more generic homes so the database carries three specializations
  class Lodge4b #(type SLOT = int, string W = "a");
    static string pile = "";
    string hold;
    SLOT sl;
    function void hb(); pile = {"<", hold=="" ? "a" : hold, ">", sl.miss()}; endfunction
  endclass
endpackage

module Top_Home4;
  import Home4_pkg::*;
  // ONE, TWO and THREE explicit specializations beside the default
  Lodge4 #(Reached4)      i1;
  Lodge4b #(Reached4, "b")  i2;
  Lodge4b #(Reached4, "c")  i3;
  Lodge4b #(Reached4, "d")  i4;
  Plain4                  p1;
  initial $display("%s", h6("a", "b"));
endmodule
