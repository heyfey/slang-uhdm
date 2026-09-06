// r10v169 arm N — A NAME COLLISION ACROSS THE CLONE BOUNDARY.  MEASUREMENT
// ONLY.  The importer declares a parameter AND a function whose names are the
// home's.  A clone body is emitted while the IMPORTER's scope is current, so
// this is the arm where a cross-listing value splice would read back the
// importer's 99 in place of the home's 23.
package p169hn;
  parameter int    kn169 = 23;
  parameter string sn169 = "en";
  function int    f_dup169(); return kn169; endfunction
  function int    f_hn169();  return kn169; endfunction
  function string f_hs169();  return sn169; endfunction
endpackage

package p169in;
  import p169hn::*;
  parameter int    kn169 = 99;
  parameter string sn169 = "ninetynine";
  function int f_dup169(); return kn169; endfunction
  function int f_in169();  return kn169; endfunction
endpackage

module v169_n_collide;
  import p169hn::*;
  import p169in::*;
  int n_i; string n_s;
  initial begin
    n_i = p169hn::f_dup169() + p169hn::f_hn169() + p169in::f_dup169() +
          p169in::f_in169();
    n_s = p169hn::f_hs169();
  end
endmodule
