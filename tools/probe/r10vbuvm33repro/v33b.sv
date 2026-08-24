// r10vbuvm33 v33b.sv — QUALIFIER SHAPES the implementer's grid does not carry.
// The $unit:: qualifier itself; a 3-segment name whose FIRST segment is a
// package that ALSO owns a typedef of the FINAL name (the CompileType.cpp:562
// getDataType collision); a class-scope PARAMETER array (the escape's class
// twin); a package LOCALPARAM array; a package parameter of TYPEDEF'd type; a
// name that is BOTH a package and a class; an ESCAPED final identifier; a
// STATIC METHOD home; a nested class qualifier.  MEASUREMENT ONLY.

int uarr33 [3];                       // a $unit-scope VARIABLE

package coll33;
  typedef int dq33;                   // a TYPEDEF named like the class array
  class inner33;
    static int dq33 [$];              // ... and the class array itself
    static int only33 [$];
  endclass
  parameter  int    PA33 [2] = '{1,2};
  localparam int    LA33 [2] = '{3,4};
  typedef    int    tp33 [2];
  parameter  tp33   TA33     = '{5,6};
  parameter  bit [3:0] PK33 [2] = '{4'h1, 4'h2};
endpackage

package both33;                       // a PACKAGE named like a class below
  int bv33 [2];
endpackage

class both33c;
  static int cv33 [2];
endclass

class outer33;
  // (forward class typedef removed: slang rejects it here)
  static int oq33 [$];
endclass

class nested33;
  static int nq33 [$];
endclass

class esc33c;
  static int \esc.name33  [$];
  static int st33 [$];
  static function void sfun33();
    foreach (esc33c::st33[i])          // W1  STATIC METHOD home, own class
      st33.push_back(i);
    foreach (esc33c::\esc.name33 [i])  // W2  ESCAPED FINAL identifier
      st33.push_back(i);
    foreach (st33[i])                  // W3  bare control
      st33.push_back(i);
  endfunction
endclass

module top33b;
  import coll33::*;
  int sink33;
  initial begin
    foreach ($unit::uarr33[i])            sink33 = i; // W4  $unit:: qualifier
    foreach (coll33::inner33::dq33[i])    sink33 = i; // W5  pkg typedef COLLISION
    foreach (coll33::inner33::only33[i])  sink33 = i; // W6  no collision twin
    foreach (coll33::PA33[i])             sink33 = i; // W7  pkg parameter array
    foreach (coll33::LA33[i])             sink33 = i; // W8  pkg LOCALPARAM array
    foreach (coll33::TA33[i])             sink33 = i; // W9  typedef'd param array
    foreach (coll33::PK33[i])             sink33 = i; // W10 packed-elem param
    foreach (both33::bv33[i])             sink33 = i; // W11 package qualifier
    foreach (both33c::cv33[i])            sink33 = i; // W12 class qualifier
    foreach (outer33::oq33[i])            sink33 = i; // W13 class qualifier
    foreach (nested33::nq33[i])           sink33 = i; // W14 second class
    foreach (uarr33[i])                   sink33 = i; // W15 bare $unit control
  end
endmodule
