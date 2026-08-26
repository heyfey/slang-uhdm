// r10v152 arm B — THE FACES of a package-scope class handle: typedef'd,
// parameterized, forward-declared, interface-class, explicitly imported,
// scoped, plus the § 142 / § 148 must-stay productions (static property,
// TF-item local, block-item local, constructor local).
package helper_pkg;
  class Widget; int wid; endclass
  class Gadget #(type T = int); T gv; endclass
  typedef class Later;
  class Later; int lt; endclass
  virtual class Abstract; pure virtual function int getv(); endclass
endpackage

package facepkg;
  import helper_pkg::Widget;              // EXPLICIT import
  import helper_pkg::*;                   // wildcard too

  typedef Widget WidgetAlias;
  typedef helper_pkg::Gadget#(byte) ByteGadget;

  class Holder;
    static Widget stat_prop;              // § 142 static class property
    int hid;
    extern function new();
    extern function void tfitem_paren();
    extern function void tfitem_bare;
  endclass

  function Holder::new();
    WidgetAlias tdef_h;                   // EATEN, TYPEDEF'd handle
    ByteGadget  spec_h;                   // ordinary local, specialization
    helper_pkg::Later scoped_h;           // ordinary local, SCOPED name
    Widget    plain_h;                    // ordinary local
    tdef_h   = null;                      // b01
    spec_h   = null;                      // b02
    scoped_h = null;                      // b03
    plain_h  = null;                      // b04
    stat_prop = null;                     // b05  static property, must not move
    hid = 1;
  endfunction

  function void Holder::tfitem_paren();
    Widget par_loc;
    par_loc = null;                       // b06  BLOCK-ITEM local (paren'd)
  endfunction

  function void Holder::tfitem_bare;
    Widget bare_loc;
    bare_loc = null;                      // b07  TF-ITEM local (paren-less)
  endfunction

  Widget par_loc;                         // package var colliding with b06
  Widget bare_loc;                        // package var colliding with b07

  class Second;
    int sid;
    extern function new;
  endclass

  function Second::new;
    ByteGadget spec_first;                // EATEN, a SPECIALIZATION handle
    Later      fwd_second;                // ordinary local, forward-declared cls
    spec_first = null;                    // b08
    fwd_second = null;                    // b09
    sid = 2;
  endfunction

endpackage

module mface;
  import facepkg::*;
  Holder h; Second s;
  initial begin
    h = new(); s = new();
    h.tfitem_paren(); h.tfitem_bare();
  end
endmodule
