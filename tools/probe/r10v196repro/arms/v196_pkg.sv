// r10uvm196 arm A — the PACKAGES.  Parameter shapes on purpose: a plain int,
// a string, a localparam, a sized literal, and a package that WILDCARD-IMPORTS
// another (so a re-export can be told apart from an own declaration).
package quarryPkg;
  parameter int    QUARRY_DEPTH   = 71;
  parameter string QUARRY_NAME    = "quarry";
  localparam int   QUARRY_LOCAL   = 12;
  parameter        QUARRY_UNTYPED = 8'hA5;
  int quarryLoose = 3;
  function automatic int quarryTake(input int a);
    return a + QUARRY_DEPTH;
  endfunction
endpackage

package masonPkg;
  import quarryPkg::*;          // re-export: masonPkg's own listing carries these
  parameter int MASON_COUNT = 5;
  function automatic int masonTake(input int a);
    return a + MASON_COUNT;
  endfunction
endpackage

package emptyParamPkg;          // a package with NO parameters at all
  int emptyLoose = 1;
  function automatic int emptyTake(input int a);
    return a;
  endfunction
endpackage
