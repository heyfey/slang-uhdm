// r10uvm186 grid ARM B — THE LISTING AXIS.  One declaration face (a plain
// subroutine body local as the SIZE argument of `d = new[n]`), read in every
// listing a database can hold:
//
//   * the HOME package's own views                     — § newArrayArgNoBind16
//   * a WILDCARD-IMPORT clone (`import P::*;`)         — § 186's own cell
//   * an EXPLICIT-import copy (`import P::fn;`)        — the R1 face
//   * the ELABORATED module that hoists the package    — § newArrayArgHoistNet130
//   * a MODULE-homed subroutine                        — § 16's HOME GUARD
//   * a `$unit`-scope subroutine                       — unitSubNoBind9's face
//
// The law must move the clone cells and NOTHING else.  Names, numbers and
// orders are deliberately unlike the corpus'.

// a $unit-scope subroutine (compilation unit home)
function automatic int corbel186(input int fml_u);
  int dyn186[];
  int loc186;
  loc186 = fml_u + 1;
  dyn186 = new[loc186];        // B6 $unit home
  return dyn186.size();
endfunction

package Mullion186;
  function automatic int rafter186(input int fml_v);
    int dyn186[];
    int loc186;
    int src186[];
    loc186 = fml_v + 2;
    src186 = new[2];
    dyn186 = new[loc186];          // B1/B2/B3/B4 the one face, four listings
    dyn186 = new[loc186](src186);  // the COPY-SOURCE twin of the same face
    return dyn186.size();
  endfunction
  function automatic int purlin186(input int fml_x);
    int dyn186[];
    int loc186;
    loc186 = fml_x + 3;
    dyn186 = new[loc186];
    return dyn186.size();
  endfunction
endpackage

// WILDCARD import — the clone
package Newel186;
  import Mullion186::*;
  int tang186 = 12;
  function automatic int use_newel186();
    return rafter186(3);
  endfunction
endpackage

// EXPLICIT import — the R1 copy face
package Astragal186;
  import Mullion186::purlin186;
  int shim186 = 13;
  function automatic int use_astragal186();
    return purlin186(4);
  endfunction
endpackage

module top186b;
  import Newel186::*;
  import Astragal186::*;
  int scored186;
  // B5 — a MODULE-homed subroutine: § 16's HOME GUARD says golden binds the
  // implicit net elaboration invents, so this cell must not move either.
  function automatic int joist186(input int fml_w);
    int dyn186[];
    int loc186;
    loc186 = fml_w + 4;
    dyn186 = new[loc186];
    return dyn186.size();
  endfunction
  initial begin
    scored186 = use_newel186() + use_astragal186() + joist186(5) + corbel186(6);
    $display("%0d", scored186);
  end
endmodule
