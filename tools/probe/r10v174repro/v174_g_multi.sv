// r10v174repro arm G — MULTIPLICITY and INHERITANCE, three packages, three
// classes each, several out-of-body methods per class, a parameterized class,
// a derived class whose out-of-body method reads an INHERITED property, and a
// nested class.  One instance can pass by accident; nine cannot.
package alcovePkg;
  typedef logic [2:0] NicheWord;
  class Sconce;
    logic [5:0] taper;
    extern function int lightOut();
    extern function int douseOut();
  endclass
  function int Sconce::lightOut();
    lightOut = $bits(byte) + $bits(taper) + $bits(NicheWord);
  endfunction
  function int Sconce::douseOut();
    douseOut = $bits(int) + $bits(taper);
  endfunction

  class Candle extends Sconce;
    logic [9:0] wick;
    extern function int burnOut();
  endclass
  // reads an INHERITED property (`taper`) from an out-of-body body
  function int Candle::burnOut();
    burnOut = $bits(byte) + $bits(wick) + $bits(taper) + $bits(NicheWord);
  endfunction

  class Lantern #(parameter int PANES = 4);
    logic [PANES-1:0] pane;
    logic [7:0]       shutter;
    extern function int glowOut();
  endclass
  function int Lantern::glowOut();
    glowOut = $bits(byte) + $bits(shutter) + $bits(pane) + $bits(NicheWord);
  endfunction
endpackage

package cloisterPkg;
  typedef bit [4:0] ArcadeWord;
  class Vault;
    logic [16:0] keystone;
    class Boss;                      // nested class
      logic [3:0] rib;
    endclass
    extern function int springOut();
    extern task springOutTask();
  endclass
  function int Vault::springOut();
    springOut = $bits(byte) + $bits(keystone) + $bits(ArcadeWord)
              + $bits(longint);
  endfunction
  task Vault::springOutTask();
    int groin;
    groin = $bits(shortint) + $bits(keystone);
  endtask
endpackage

package narthexPkg;
  typedef logic [6:0] TympanumWord;
  class Portal;
    logic [20:0] jamb;
    extern function int swingOut();
  endclass
  function int Portal::swingOut();
    swingOut = $bits(byte) + $bits(jamb) + $bits(TympanumWord) + $bits(shortint);
  endfunction
  class Lintel;
    logic [1:0] soffit;
    extern function int bearOut();
  endclass
  function int Lintel::bearOut();
    bearOut = $bits(byte) + $bits(soffit) + $bits(TympanumWord);
  endfunction
endpackage

module alcoveTop; alcovePkg::Candle cd = new(); cloisterPkg::Vault vt = new(); narthexPkg::Portal pt = new(); int r; initial r = cd.burnOut() + vt.springOut() + pt.swingOut(); endmodule
