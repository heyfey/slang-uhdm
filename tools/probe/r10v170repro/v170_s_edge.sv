// r10v170 arm S — EDGE SHAPES: a package with NO instantiating module (a
// DEF-only elaboration path), a cast whose target is a TYPE PARAMETER, a class
// HANDLE typedef, an enum typedef reached through a `parameter type`, a
// generate block in the same file, and a module-scope export beside a
// package-scope one so both answers are in ONE compilation.
package OnlyDefS9;
  typedef enum bit [1:0] { OD_P, OD_Q } Phase_e;
  typedef struct packed { bit [2:0] g; } Gauge_s;
  function void wellS9(int q);
  endfunction
  export "DPI-C" function driftS9;
  function void driftS9(int v);
    wellS9(int'(Phase_e'(v)));       // u01 no module ever instantiates this pkg
    wellS9(int'(Gauge_s'(v)));       // u02
  endfunction
  function void steadyS9(int v);
    wellS9(int'(Phase_e'(v)));       // u03 control
  endfunction
endpackage

package ParamS9;
  typedef enum bit [1:0] { PS_L, PS_R } Side_e;
  typedef Side_e SideBy_e;
  class HolderS9 #(type T = Side_e);
    T slot;
    function void put(int v);
      slot = T'(v);                  // u04 cast to a TYPE PARAMETER
    endfunction
  endclass
  typedef HolderS9#(Side_e) HandleS9;   // a class-handle typedef

  function void plugS9(int q);
  endfunction
  export "DPI-C" function knotS9;
  function void knotS9(int v);
    plugS9(int'(Side_e'(v)));        // u05 exported, bare own enum
    plugS9(int'(SideBy_e'(v)));      // u06 exported, alias of own enum
  endfunction
  function void loopS9(int v);
    plugS9(int'(Side_e'(v)));        // u07 control
    plugS9(int'(SideBy_e'(v)));      // u08 control
  endfunction
endpackage

module modS9 #(parameter int N = 2) ();
  typedef enum bit [1:0] { MS0, MS1 } Mode_e;
  function void fanS9(int q);
  endfunction
  export "DPI-C" function beatS9;
  function void beatS9(int v);
    fanS9(int'(Mode_e'(v)));         // u09 MODULE-scope export -> must resolve
    fanS9(int'(ParamS9::Side_e'(v)));// u10
  endfunction
  for (genvar gi = 0; gi < 2; gi++) begin : gS9
    function automatic void inGenS9(int v);
      fanS9(int'(Mode_e'(v)));       // u11 inside a generate block
    endfunction
    initial inGenS9(gi);
  end
  initial beatS9(N);
endmodule

module topS170;
  modS9 #(.N(3)) u_a ();
  initial ParamS9::loopS9(1);
endmodule
