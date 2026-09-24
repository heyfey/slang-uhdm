// v7 — FILE-SCOPE import, and an interface in the same file that imports
// NOTHING of its own.  Surelog's file-scope pre-pass reaches every module
// definition written in the same file; does it reach this interface?
package pv7;
  int fv7 = 1;
  string fs7 = "f";
endpackage

import pv7::*;

interface if_v7_noimport;
  logic own_v7a;
endinterface

interface if_v7_alsoimports;
  import pv7::*;
  logic own_v7b;
endinterface

module m_v7_noimport;
  logic own_mv7;
endmodule
