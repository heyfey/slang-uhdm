// r10v169 arm H — the RETURN TYPE against the PARAMETER TYPE, and CASTS.
// MEASUREMENT ONLY.  The fold copies the param_assign Rhs VERBATIM, so a
// function whose return type is NARROWER or WIDER than the parameter, and a
// cast written over the read, are the faces where a verbatim copy can be
// wrong in a way a re-render would not be.
package p169hh;
  parameter int       kh169 = 9;
  parameter bit [7:0] vh169 = 8'hA5;
  parameter string    sh169 = "aitch";
  typedef enum int { ha169 = 1, hb169 = 2 } eh169_t;
  parameter eh169_t   eh169 = hb169;

  function bit [3:0] f_narrow169();  return kh169;        endfunction
  function longint   f_wide169();    return kh169;        endfunction
  function int       f_widep169();   return vh169;        endfunction
  function int       f_cast169();    return int'(vh169);  endfunction
  function int       f_castp169();   return int'(kh169);  endfunction
  function eh169_t   f_enum169();    return eh169;        endfunction
  function int       f_enumint169(); return int'(eh169);  endfunction
  function real      f_realc169();   return real'(kh169); endfunction
  function string    f_strc169();    return string'(sh169); endfunction
  function bit [7:0] f_exact169();   return vh169;        endfunction
endpackage

package p169ih;
  import p169hh::*;
  parameter int ownh169 = 7;
  function int f_ownh169(); return ownh169; endfunction
endpackage

module v169_h_types;
  import p169hh::*;
  import p169ih::*;
  int h_i; real h_r; string h_s; bit [7:0] h_v;
  initial begin
    h_i = f_narrow169() + int'(f_wide169()) + f_widep169() + f_cast169() +
          f_castp169() + int'(f_enum169()) + f_enumint169() + f_ownh169();
    h_r = f_realc169();
    h_s = f_strc169();
    h_v = f_exact169();
  end
endmodule
